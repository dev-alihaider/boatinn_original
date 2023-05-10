# frozen_string_literal: true

module Admin::GeneralHelper # :nodoc:
  def turn_on_of(view_type, entity)
    entity.send(view_type) ? 'enabled' : 'disabled'
  end

  def fields_for_sharing_title(figure)
    if figure.positive?
      "community_for_sharing_title_image_#{figure}".to_sym
    else
      :community_for_sharing_title
    end
  end

  def fields_for_sharing_descr(figure)
    if figure.positive?
      "community_for_sharing_descr_image_#{figure}".to_sym
    else
      :community_for_sharing_descr
    end
  end

  def show_color_on_sharing(figure)
    figure <= 0
  end

  def title_for_sharing(figure)
    if figure.positive?
      "#{t('admin.dashboard.homepage.community_for_sharing.general.title')} #{figure}"
    else
      t('admin.dashboard.homepage.community_for_sharing.general.title')
    end
  end

  def descr_for_sharing(figure)
    if figure.positive?
      "#{t('admin.dashboard.homepage.community_for_sharing.general.descr')} #{figure}"
    else
      t('admin.dashboard.homepage.community_for_sharing.general.descr')
    end
  end

  def descr_for_strip_color(figure)
    if figure.positive?
      "#{t('admin.general.strip_color')} #{figure}"
    else
      t('admin.general.strip_color')
    end
  end

  def for_globalize_hidden(locale)
    locale == 'en' ? %i[form-control tab-content] : %i[form-control tab-content hidden]
  end

  def locale_image(locale, options = nil)
    language_icons = { en: 'United-States',
                       de: 'Germany',
                       ru: 'Russia',
                       fr: 'France',
                       es: 'Spain',
                       it: 'Italy' }

    image_tag("admin/#{language_icons[locale.to_sym]}.png", options)
  end
end
