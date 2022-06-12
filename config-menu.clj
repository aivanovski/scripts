#!/usr/bin/env bb

; Launch Rofi with selection of config files to edit

(require '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str])

(defn run [command]
  (def result (sh "bash" "-c" command))
  (if (contains? result :out)
        (get result :out)
        (System/exit 0)))

(def files ["~/.bashrc"
            "~/.vimrc"
            "~/.ideavimrc"
            "~/.config/i3/config"
            "~/.config/polybar/config.ini"
            "~/.config/nvim"])

(def selected-file 
  (str/trim
    (run
      (format "echo '%s' | rofi -sep '|' -dmenu -i | xargs -r echo"
              (str/join "|" files)))))

(when (not-empty selected-file)
  (sh "terminator" "--command"
      (format "nvim %s"
              (str/replace selected-file "~" "$HOME"))))
