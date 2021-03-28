(import
  json
  os)

(setv default-config {"prefix" "+"  "token" ""  "database" ""})

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
        (.dump json default-config file)))
    (with [file (open filename)]
      (setv self.config (.load json file)))
    (setv self.prefix (.config.get self "prefix" (.get default-config "prefix")))
    (setv self.token (.config.get self "token" (.get default-config "token")))
    (setv self.database (.config.get self "database" (.get default-config "database"))))
  (defn store [self]
    (setv c {"prefix" self.prefix  "token" self.token  "database" self.database})
    (with [file (open self.filename "w")]
      (.dump json c file))))
