# frozen_string_literal: true
# == Schema Information
#
# Table name: invites
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  code                       :string           default(""), not null
#  expires_at                 :datetime
#  max_uses                   :integer
#  uses                       :integer          default(0), not null
#  default_follow_account_ids :integer          is an Array
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Invite < ApplicationRecord
  belongs_to :user, required: true
  has_many :users, inverse_of: :invite

  before_validation :set_code

  attr_reader :expires_in

  def expires_in=(interval)
    self.expires_at = interval.to_i.seconds.from_now
    @expires_in     = interval
  end

  def valid_for_use?
    (max_uses.nil? || uses < max_uses) && (expires_at.nil? || expires_at <= Time.now.utc)
  end

  private

  def set_code
    loop do
      self.code = ([*('a'..'z'), *('A'..'Z'), *('0'..'9')] - %w(0 1 I l O)).sample(8).join
      break if Invite.find_by(code: code).nil?
    end
  end
end
