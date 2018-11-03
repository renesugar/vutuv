defmodule Vutuv.Emailer do
  import Bamboo.Email
  require Ecto.Query
  require Vutuv.Gettext
  use Bamboo.Phoenix, view: Vutuv.EmailView
  alias Vutuv.Repo
  alias Vutuv.User

  def login_email({link, pin}, email, %Vutuv.User{validated?: false} = user) do
    gen_email(link, pin, email, user, "registration_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your vutuv account"))
  end

  def login_email({link, pin}, email, user) do
    gen_email(link, pin, email, user, "login_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Login to vutuv"))
  end

  def fbs_login_email({link, pin}, email, %Vutuv.User{validated?: false} = user) do
    gen_email(link, pin, email, user, "fbs_registration_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your vutuv account"))
  end

  def fbs_login_email({link, pin}, email, user) do
    gen_email(link, pin, email, user, "fbs_login_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Login to vutuv"))
  end

  def email_creation_email({link, pin}, email, user) do

    gen_email(link, pin, email, user,"email_creation_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your email"))
  end

  def user_deletion_email({link, pin}, email, user) do
    gen_email(link, pin, email, user,"user_deletion_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your account deletion"))
  end

  def payment_information_email(recruiter_subscription, user, email) do
    recuiter_package = Vutuv.Repo.get(Vutuv.RecruiterPackage, recruiter_subscription.recruiter_package_id)
    template = "payment_information_email_#{get_locale(user.locale)}"
    accounting_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:accounting_email]

		admin_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_name]
		admin_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_email]
	
		url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:public_url]
		
    new_email()
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
    |> assign(:recuiter_package, recuiter_package)
    |> assign(:recruiter_subscription, recruiter_subscription)
		|> assign(:url, url)
    |> assign(:user, user)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> bcc("#{accounting_email}")
    |> from("#{admin_name} <#{admin_email}>")
    |> subject(Vutuv.Gettext.gettext("Order")<>" \"#{recuiter_package.name}\" "<>Vutuv.Gettext.gettext("subscription"))
    |> render("#{template}.text")
  end

  def issue_invoice(recruiter_subscription, user, _email) do
		template = "trigger_recruiter_subscription_invoice_#{get_locale(user.locale)}"
				
    accounting_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:accounting_email]

		admin_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_name]
		admin_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_email]
		
		url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:public_url]

    if accounting_email do
      recuiter_package = Vutuv.Repo.get(Vutuv.RecruiterPackage, recruiter_subscription.recruiter_package_id)

      new_email()
      |> put_text_layout({Vutuv.EmailView, "trigger_recruiter_subscription_invoice.text"})
      |> assign(:recruiter_subscription, recruiter_subscription)
      |> assign(:recuiter_package, recuiter_package)
		  |> assign(:url, url)
      |> assign(:user, user)
      |> to("#{accounting_email}")
      |> from("#{admin_name} <#{admin_email}>")
      |> subject(Vutuv.Gettext.gettext("Invoice")<>" \"#{recuiter_package.name}\" "<>Vutuv.Gettext.gettext("subscription"))
      |> render("#{template}.text")
      |> Vutuv.Mailer.deliver_now
    end
  end


  def verification_notice(user) do
		template = "verification_confirmation_#{get_locale(user.locale)}"

    email = Vutuv.Repo.one(Ecto.Query.from e in Vutuv.Email, where: e.user_id == ^user.id, limit: 1, select: e.value)
		
		admin_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_name]
		admin_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_email]
		
		url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:public_url]
				
    new_email()
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
		|> assign(:url, url)
    |> assign(:user, user)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> from("#{admin_name} <#{admin_email}>")
    |> subject(Vutuv.Gettext.gettext("vutuv Account verified"))
    |> render("#{template}.text")
    |> Vutuv.Mailer.deliver_now
  end

  def birthday_reminder(user, birthday_childs, future_birthday_childs) do
    {{today_year, _month, _day}, {_, _, _}} = :calendar.local_time()

    name_list = for(birthday_child <- birthday_childs) do
      {:ok, {birthday_year, _, _}} = Ecto.Date.dump(birthday_child.birthdate)
      case birthday_year do
        1900 ->
          Vutuv.UserHelpers.full_name(birthday_child)
        _ ->
          "#{Vutuv.UserHelpers.full_name(birthday_child)} (#{today_year - birthday_year})"
      end
    end

    # Don't let the subject become to long.
    #
    full_names_with_age = Enum.join(name_list, ", ")
    truncated_subject = if String.length(full_names_with_age) > 50 do
      "#{String.slice(full_names_with_age, 0..45)} ..."
    else
      full_names_with_age
    end

    template = "birthday_reminder_#{get_locale(user.locale)}"

    email = Vutuv.Repo.one(Ecto.Query.from e in Vutuv.Email, where: e.user_id == ^user.id, limit: 1, select: e.value)

		admin_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_name]
		admin_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_email]
		
		url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:public_url]
				
    Gettext.put_locale(Vutuv.Gettext, user.locale)

    new_email()
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
		|> assign(:url, url)
    |> assign(:user, user)
    |> assign(:birthday_childs, birthday_childs)
    |> assign(:future_birthday_childs, future_birthday_childs)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> from("#{admin_name} <#{admin_email}>")
    |> subject("#{Vutuv.Gettext.gettext("Birthday")}: #{truncated_subject}")
    |> render("#{template}.text")
  end

  def enrichment_trigger(user) do
    user = Repo.get(User, user.id) |> Repo.preload([:followees]) |> Repo.preload([:followers])

    if Vutuv.Fullcontact.enrichable_websites(user) != [] || Vutuv.Fullcontact.enrichable_social_media_accounts(user) > 0 || Vutuv.Fullcontact.enrichable_work_experiences(user) != nil do
      follower_count = length(user.followers)
      followee_count = length(user.followees)

      now = :calendar.local_time()
      {days_since_inserted_at, {_, _, _}} = :calendar.time_difference(user.inserted_at |> Ecto.DateTime.to_erl, now)

      template = "enrichment_trigger_#{get_locale(user.locale)}"

      email = Vutuv.Repo.one(Ecto.Query.from e in Vutuv.Email, where: e.user_id == ^user.id, limit: 1, select: e.value)

      url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:public_url]
		
			admin_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_name]
			admin_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_email]

			contact_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:contact_name]
			contact_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:contact_email]
			
      Gettext.put_locale(Vutuv.Gettext, user.locale)

      new_email()
      |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
			|> assign(:url, url)
      |> assign(:user, user)
      |> assign(:follower_count, follower_count)
      |> assign(:followee_count, followee_count)
      |> assign(:days_since_inserted_at, days_since_inserted_at)
      |> assign(:enrichable_websites, Vutuv.Fullcontact.enrichable_websites(user))
      |> assign(:enrichable_social_media_accounts, Vutuv.Fullcontact.enrichable_social_media_accounts(user))
      |> assign(:enrichable_work_experiences, Vutuv.Fullcontact.enrichable_work_experiences(user))
      |> assign(:enrichable_avatar, Vutuv.Fullcontact.enrichable_avatar(user))
      # |> assign(:enrichable_websites, Vutuv.Fullcontact.fullcontact_websites(user))
      # |> assign(:enrichable_social_media_accounts, Vutuv.Fullcontact.fullcontact_social_media_accounts(user))
      # |> assign(:enrichable_work_experiences, Vutuv.Fullcontact.fullcontact_work_experiences(user))
      # |> assign(:enrichable_avatar, Vutuv.Fullcontact.fullcontact_avatars(user) |> List.first)
      |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
      |> bcc("#{contact_name} <#{contact_email}>")
      |> from("#{admin_name} <#{admin_email}>")
      |> subject("#{Vutuv.Gettext.gettext("Enrich your vutuv profile")}")
      |> render("#{template}.text")
    end
  end

  defp gen_email(link, pin, email, user, template, email_subject) do
    url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:public_url]
		
		admin_name  = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_name]
		admin_email = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:admin_email]
		
    new_email()
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
    |> assign(:link, link)
    |> assign(:pin, pin)
    |> assign(:url, url)
    |> assign(:user, user)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> from("#{admin_name} <#{admin_email}>")
    |> subject(email_subject)
    |> render("#{template}.text")
  end

  defp get_locale(nil), do: "en"

  defp get_locale(locale) do
    if(Vutuv.Plug.Locale.locale_supported?(locale)) do
      locale
    else
      "en"
    end
  end
end
