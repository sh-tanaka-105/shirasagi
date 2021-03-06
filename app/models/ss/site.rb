class SS::Site
  include SS::Model::Site
  include SS::Addon::MobileSetting
  include SS::Addon::MapSetting
  include SS::Addon::KanaSetting
  include SS::Addon::FacebookSetting
  include SS::Addon::TwitterSetting
  include SS::Addon::SiteAutoPostSetting
  include SS::Addon::FileSetting
  include SS::Addon::MailSetting
  include SS::Addon::TrashSetting
  include SS::Addon::ApproveSetting
  include SS::Addon::EditorSetting
  include SS::Addon::Elasticsearch::SiteSetting
  include SS::Addon::SiteUsage
end
