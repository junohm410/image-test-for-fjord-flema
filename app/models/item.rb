# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :user
  belongs_to :buyer, class_name: 'User', optional: true, inverse_of: :buyable_items
  has_many :purchase_requests, dependent: :destroy
  has_many :requesting_users, through: :purchase_requests, source: :user
  has_many :comments, dependent: :destroy
  has_many_attached :images

  enum status: { listed: 0, unpublished: 1, buyer_selected: 2 }

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :shipping_cost_covered, inclusion: { in: [true, false] }
  validates :deadline, presence: true
  validate :deadline_later_than_today, unless: -> { validation_context == :select_buyer }

  scope :accessible_for, ->(user) { where(user:).or(not_unpublished) }
  scope :closed_yesterday, -> { listed.where('deadline < ?', Time.current.beginning_of_day) }

  def changed_to_listed_from_unpublished?
    saved_change_to_status == %w[unpublished listed]
  end

  def changed_to_unpublished_from_listed?
    saved_change_to_status == %w[listed unpublished]
  end

  private

  def deadline_later_than_today
    return if deadline.present? && deadline >= Time.current.beginning_of_day

    errors.add(:deadline, "can't be earlier than today")
  end
end
