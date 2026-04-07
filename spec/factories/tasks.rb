FactoryBot.define do
  factory :task do
    association :user
    title { 'テストタスク' }
    source_type { 'Slack' }
    due_date { Date.today }
    is_routine { false }
    is_today { false }
    archived { false }
    status { :todo }

    # 日常業務（マスター）用のトレイト
    trait :routine do
      is_routine { true }
      source_type { nil }
      due_date { nil }
    end
  end
end
