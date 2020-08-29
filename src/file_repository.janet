(defn- build-day [date]
  @{:date date :tasks (array)})

(defn- day-title? [line] (string/find "## " line))

(defn- task? [line] (string/find "- [" line))

(defn- add-new-day [days line]
  (array/push days (build-day (string/slice line 3))))

(defn- add-new-task [day line]
  (array/push (day :tasks) line))

(defn- process-line [days line]
  (if (day-title? line)
    (add-new-day days line))
  (if (task? line)
    (add-new-task (array/peek days) line))
  days)

(defn read-lines
  ```
  Read lines from the file on the file path.
  Returns a struct:

    {:lines lines}   - When the file was successfully read.
    {:error message} - When the file was not successfully read.

  ```
  [path]
  (if (= (os/stat path) nil)
    {:error "File does not exist"}
    (let [file (file/read (file/open path) :all)
          lines (string/split "\n" file)]
      {:lines lines})))

(defn read-schedule
  ```
  Read a schedule from a file.
  Returs a struct:

    {:days [
      {:date "2020-08-01" :tasks ["- [  ] Develop photos" "- [ ] Pay bills"]}
      {:date "2020-07-31" :tasks ["- [  ] Review bugs"]}
    ]}

  Or an error struct:

    {:error message} - When the file was not successfully read.
  ```
  [path]
  (let [result (read-lines path)]
    (if (result :error)
      result
      {:days (reduce process-line (array) (result :lines))})))