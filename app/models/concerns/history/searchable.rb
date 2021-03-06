module History::Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(params)
      criteria = self.where({})
      return criteria if params.blank?

      if params[:keyword].present?
        words = params[:keyword].split(/[\s　]+/).uniq.compact if params[:keyword].is_a?(String)
        words = words[0..4]
        cond  = words.map do |word|
          inner_cond = []

          # action
          inner_cond << { action: word }

          # controller
          inner_cond << { controller: word.pluralize }

          models = I18n.t(:"mongoid.models").invert
          inner_cond << { controller: models[word].to_s.pluralize } if models[word].present?

          # session_id
          inner_cond << { session_id: word }

          # request_id
          inner_cond << { request_id: word }

          # user_name
          user_ids = SS::User.where(name: /#{::Regexp.escape(word)}/i).pluck(:id)
          inner_cond << { user_id: { "$in" => user_ids } } if user_ids.present?

          { "$or" => inner_cond }
        end

        criteria = criteria.where("$and" => cond)
      end
      criteria
    end
  end
end
