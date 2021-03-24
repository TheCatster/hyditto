(import
  json
  os)

(setv default_config {"prefix" "+"  "token" ""  "database" ""})

(defclass Config []

  (setv filename "")
  (setv config {})
  (setv prefix "")
  (setv token "")
  (setv database "")

  (defn __init__ [self &optional [filename "config.json"]]
    (setv self.filename filename)
    (setv self.config {})
    (if (not (.path.isfile os filename))
      (with [file (open filename "w")]
        (.dump json default_config file)))
    (with [file (open filename)]
      (setv self.config (.load json file)))
    (setv self.prefix (.config.get self "prefix" (.get default_config "prefix")))
    (setv self.token (.config.get self "token" (.get default_config "token")))
    (setv self.database (.config.get self "database" (.get default_config "database"))))
  (defn store [self]
    (setv c {"prefix" self.prefix  "token" self.token  "database" self.database})
    (with [file (open self.filename "w")]
      (.dump json c file))))
