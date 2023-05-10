# frozen_string_literal: true

json.extract! review, :id, :public_review, :private_review,
              :rating_cleanliness, :rating_communication, :rating_boat_rules,
              :would_recommend
