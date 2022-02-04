(import testament :prefix "" :exit true)

(import ../../src/date :as "d")
(import ../../src/plan)
(import ../../src/day)
(import ../../src/task)
(import ../../src/commands/schedule_tasks :prefix "")

## -----------------------------------------------------------------------------
## Test scheduled-for?

(deftest scheduled-for-monday
  (def task (task/build-scheduled-task "Weekly meeting" "every Monday"))
  (is (scheduled-for? task (d/date 2022 1 24)))
  (is (not (scheduled-for? task (d/date 2022 1 25)))))

(deftest scheduled-for-tuesday
  (def task (task/build-scheduled-task "Weekly meeting" "every Tuesday"))
  (is (not (scheduled-for? task (d/date 2022 1 24))))
  (is (scheduled-for? task (d/date 2022 1 25))))

(deftest scheduled-for-every-month
  (def task (task/build-scheduled-task "Review logs" "every month"))
  (is (scheduled-for? task (d/date 2022 1 1)))
  (is (not (scheduled-for? task (d/date 2022 1 2))))
  (is (scheduled-for? task (d/date 2022 6 1)))
  (is (not (scheduled-for? task (d/date 2022 6 15)))))

(deftest scheduled-for-every-3-months
  (def task (task/build-scheduled-task "Review logs" "every 3 months"))
  (is (scheduled-for? task (d/date 2022 1 1)))
  (is (not (scheduled-for? task (d/date 2022 2 1))))
  (is (not (scheduled-for? task (d/date 2022 3 1))))
  (is (scheduled-for? task (d/date 2022 4 1)))
  (is (not (scheduled-for? task (d/date 2022 5 1))))
  (is (not (scheduled-for? task (d/date 2022 6 1))))
  (is (scheduled-for? task (d/date 2022 7 1)))
  (is (not (scheduled-for? task (d/date 2022 8 1))))
  (is (not (scheduled-for? task (d/date 2022 9 1))))
  (is (scheduled-for? task (d/date 2022 10 1))))

(deftest scheduled-for-every-weekday
  (def task (task/build-scheduled-task "Review logs" "every weekday"))
  (is (scheduled-for? task (d/date 2022 1 24)))        # Monday
  (is (scheduled-for? task (d/date 2022 1 25)))        # Tuesday
  (is (scheduled-for? task (d/date 2022 1 26)))        # Wednesday
  (is (scheduled-for? task (d/date 2022 1 27)))        # Thursday
  (is (scheduled-for? task (d/date 2022 1 28)))        # Friday
  (is (not (scheduled-for? task (d/date 2022 1 29))))  # Saturday
  (is (not (scheduled-for? task (d/date 2022 1 30))))) # Sunday

(deftest scheduled-for-specific-date-every-year
  (def task (task/build-scheduled-task "Review logs" "every year on 01-27"))
  (is (scheduled-for? task (d/date 2022 1 27)))
  (is (scheduled-for? task (d/date 2023 1 27)))
  (is (scheduled-for? task (d/date 2024 1 27)))
  (is (not (scheduled-for? task (d/date 2022 1 26))))
  (is (not (scheduled-for? task (d/date 2022 1 28))))
  (is (not (scheduled-for? task (d/date 2022 2 1)))))

(deftest scheduled-for-specific-date
  (def task (task/build-scheduled-task "Review logs" "on 2022-01-27"))
  (is (scheduled-for? task (d/date 2022 1 27)))
  (is (not (scheduled-for? task (d/date 2022 1 26))))
  (is (not (scheduled-for? task (d/date 2022 1 28))))
  (is (not (scheduled-for? task (d/date 2022 2 1))))
  (is (not (scheduled-for? task (d/date 2023 1 27)))))

## -----------------------------------------------------------------------------
## Test schedule-tasks

(defn build-plan []
  (plan/build-plan "My Plan" @[]
                   @[(day/build-day (d/date 2022 1 18))
                     (day/build-day (d/date 2022 1 17))]))
(def scheduled-tasks
  @[(task/build-scheduled-task "Weekly meeting" "every Monday")])

(deftest schedule-task-on-specific-weekday
  (def plan (build-plan))
  (schedule-tasks plan scheduled-tasks (d/date 2022 1 17))
  (is (empty? (((plan :days) 0) :tasks)))
  (is (= {:title "Weekly meeting" :done false :schedule "every Monday"}
         ((((plan :days) 1) :tasks) 0))))

(deftest schedule-tasks-does-not-insert-duplicate-tasks
  (def plan (build-plan))
  (schedule-tasks plan scheduled-tasks (d/date 2022 1 17))
  (schedule-tasks plan scheduled-tasks (d/date 2022 1 17))
  (is (empty? (((plan :days) 0) :tasks)))
  (is (= 1 (length (((plan :days) 1) :tasks)))))

(run-tests!)