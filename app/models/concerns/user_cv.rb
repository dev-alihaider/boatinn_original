# frozen_string_literal: true

module UserCv # :nodoc:
  extend ActiveSupport::Concern

  included do
    def self.cvs
      {
        boating_experience: boating_experience,
        your_level: your_level,
        your_preference: your_preference,
        hold_license: hold_license,
        name_license: name_license,
        country_expedition: country_expedition,
        description: description
      }
    end

    def self.cvs_select
      cvs.slice(:boating_experience, :your_level,
                :your_preference, :hold_license)
    end

    def self.cvs_country
      cvs.slice(:country_expedition)
    end

    def self.cvs_description
      cvs.slice(:description)
    end

    def self.cvs_license
      cvs.slice(:name_license)
    end

    def self.boating_experience
      {
        name: I18n.t('users.cv.boating_experience'),
        options: {
          under_1: I18n.t('users.cv.boating_experience_options.under_1'),
          one_year: I18n.t('users.cv.boating_experience_options.one_year'),
          more_that_one_year: I18n.t('users.cv.boating_experience_options.more_that_one_year')
        }
      }
    end

    def self.your_level
      {
        name: I18n.t('users.cv.your_level'),
        options: {
          pro: I18n.t('users.cv.your_level_options.pro'),
          amateur: I18n.t('users.cv.your_level_options.amateur')
        }
      }
    end

    def self.your_preference
      {
        name: I18n.t('users.cv.your_preference'),
        options: {
          sail_boat: I18n.t('users.cv.your_preference_options.sail_boat'),
          motorboat: I18n.t('users.cv.your_preference_options.motorboat')
        }
      }
    end

    def self.hold_license
      {
        name: I18n.t('users.cv.hold_license'),
        options: {
          costal: I18n.t('users.cv.hold_license_options.costal'),
          offshore: I18n.t('users.cv.hold_license_options.offshore')
        }
      }
    end

    def self.name_license
      { name: I18n.t('users.cv.name_license') }
    end

    def self.country_expedition
      { name: I18n.t('users.cv.country_expedition') }
    end

    def self.description
      { name: I18n.t('users.cv.description') }
    end
  end
end
