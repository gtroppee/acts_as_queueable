# This migration is added to circumvent issue #623 and have special characters
# work properly
class ChangeCollationForQueueNames < ActiveRecord::Migration
  def up
    if ActsAsQueueable::Utitls.using_mysql?
      execute("ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;")
    end
  end
end
