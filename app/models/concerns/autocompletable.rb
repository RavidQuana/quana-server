module Autocompletable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :autocompletable_opts

    def autocompletable(opts = {})
      @autocompletable_opts = opts
    end
  end

  included do
		# TODO add docs
    scope :autocomplete, ->(q, exact_match, scope = nil) {
      base = autocompletable_opts[:joins] ? joins(autocompletable_opts[:joins]) : all
      query = autocompletable_opts[:query_by].map {|attr| "LOWER(#{attr}) LIKE :term"}
      result = exact_match ? base.where(exact_match => q) : (q ? base.where(["cast(#{self.name.underscore.pluralize}.id
        AS text) LIKE :term OR #{query.join(' OR ')}", term: q.downcase + '%']).where(scope).distinct : base.where(scope))
    }
  end

  def autocomplete_text
    template = get_autocompletable_opts[:display_as]
    keys = template.scan(/%{(\w*)}/).flatten

    template % keys.inject({}) {|memo, k| memo[k.to_sym] = self.send(k); memo}
  end

  def autocomplete_item
    {id: id, text: "#{autocomplete_text}"}
  end

  def select2_item
    {"#{autocomplete_text}" => id}
  end

  def bip_item
    {id => autocomplete_text}
  end

  def get_autocompletable_opts
    self.class.autocompletable_opts || {}
  end
end