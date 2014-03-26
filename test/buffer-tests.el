(require 'ert)
(require 'ert-expectations)
(require 'el-mock)

(expectations
  (expect "hello there\nhow are you today\nthis is a hell of a ride" (orgtrello-buffer/filter-out-properties ":PROPERTIES:
:orgtrello-id: 52c945143004d4617c012528
:END:
hello there
how are you today
this is a hell of a ride"))
  (expect "hello there\nhow are you today\nthis is a hell of a ride" (orgtrello-buffer/filter-out-properties "hello there
how are you today
this is a hell of a ride")))

(expectations (desc "orgtrello-buffer/extract-description-from-current-position! - standard org-trello properties without blanks before them.")
  (expect "hello there"
    (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
:PROPERTIES:
:orgtrello-id: 52c945143004d4617c012528
:END:
hello there
"
      (orgtrello-buffer/extract-description-from-current-position!)))

    (expect "hello there"
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
:PROPERTIES:
:orgtrello-id: 52c945143004d4617c012528
:END:
hello there
- [-] LISP family   :PROPERTIES: {\"orgtrello-id\":\"52c945140a364c5226007314\"}
  - [X] Emacs-Lisp  :PROPERTIES: {\"orgtrello-id\":\"52c9451784251e1b260127f8\"}
  - [X] Common-Lisp :PROPERTIES: {\"orgtrello-id\":\"52c94518b2c5b28e37012ba4\"}"
       (orgtrello-buffer/extract-description-from-current-position!)))

    (expect "hello there\n"
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
:PROPERTIES:
:orgtrello-id: 52c945143004d4617c012528
:END:

hello there

- [-] LISP family   :PROPERTIES: {\"orgtrello-id\":\"52c945140a364c5226007314\"}
  - [X] Emacs-Lisp  :PROPERTIES: {\"orgtrello-id\":\"52c9451784251e1b260127f8\"}
  - [X] Common-Lisp :PROPERTIES: {\"orgtrello-id\":\"52c94518b2c5b28e37012ba4\"}"
       (orgtrello-buffer/extract-description-from-current-position!)))

    (expect nil
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES" (orgtrello-buffer/extract-description-from-current-position!)))

    (expect ""
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
:PROPERTIES:
:orgtrello-id: 52c945143004d4617c012528
:END:
- [-] LISP family   :PROPERTIES: {\"orgtrello-id\":\"52c945140a364c5226007314\"}"
       (orgtrello-buffer/extract-description-from-current-position!))))

(expectations (desc "orgtrello-buffer/extract-description-from-current-position! - non standard org-trello properties with blanks before them.")
  (expect "hello there"
    (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
 :PROPERTIES:
 :orgtrello-id: 52c945143004d4617c012528
 :END:
hello there
"
      (orgtrello-buffer/extract-description-from-current-position!)))

    (expect "hello there"
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
 :PROPERTIES:
 :orgtrello-id: 52c945143004d4617c012528
    :END:
hello there
- [-] LISP family   :PROPERTIES: {\"orgtrello-id\":\"52c945140a364c5226007314\"}
  - [X] Emacs-Lisp  :PROPERTIES: {\"orgtrello-id\":\"52c9451784251e1b260127f8\"}
  - [X] Common-Lisp :PROPERTIES: {\"orgtrello-id\":\"52c94518b2c5b28e37012ba4\"}"
       (orgtrello-buffer/extract-description-from-current-position!)))

    (expect "hello there\n"
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
  :PROPERTIES:
         :orgtrello-id: 52c945143004d4617c012528
  :END:

hello there

- [-] LISP family   :PROPERTIES: {\"orgtrello-id\":\"52c945140a364c5226007314\"}
  - [X] Emacs-Lisp  :PROPERTIES: {\"orgtrello-id\":\"52c9451784251e1b260127f8\"}
  - [X] Common-Lisp :PROPERTIES: {\"orgtrello-id\":\"52c94518b2c5b28e37012ba4\"}"
       (orgtrello-buffer/extract-description-from-current-position!)))
    (expect ""
      (orgtrello-tests/with-temp-buffer "* TODO Joy of FUN(ctional) LANGUAGES
  :PROPERTIES:
 :orgtrello-id: 52c945143004d4617c012528
:END:
- [-] LISP family   :PROPERTIES: {\"orgtrello-id\":\"52c945140a364c5226007314\"}"
                                        (orgtrello-buffer/extract-description-from-current-position!))))

(expectations (desc "orgtrello-buffer/filter-out-properties - removing lines starting with org-trello metadata properties.")
  (expect "no filter happens here." (orgtrello-buffer/filter-out-properties "no filter happens here."))
  (expect "no filter happens here." (orgtrello-buffer/filter-out-properties "   no filter happens here."))
  (expect "" (orgtrello-buffer/filter-out-properties ":PROPERTIES: filter happens and blank is left."))
  (expect "" (orgtrello-buffer/filter-out-properties "  :PROPERTIES: filter still happens and blank is left."))
  (expect "multiple lines\n" (orgtrello-buffer/filter-out-properties "  multiple lines\n  :PROPERTIES: filter still happens and blank is left.")))

(expectations
 (expect "some-comments###with-dummy-data"
         (orgtrello-tests/with-temp-buffer
          "* card
:PROPERTIES:
:orgtrello-card-comments: some-comments###with-dummy-data
:END:"
          (orgtrello-buffer/get-card-comments!))))

(expectations
  (expect
      "this-is-the-board-id"
    (orgtrello-tests/with-org-buffer
      (format ":PROPERTIES:\n#+PROPERTY: %s this-is-the-board-id\n:END:\n* card\n" *BOARD-ID*)
      (orgtrello-buffer/board-id!)))
  (expect "this-is-the-board-name"
    (orgtrello-tests/with-org-buffer
     (format ":PROPERTIES:\n#+PROPERTY: %s this-is-the-board-name\n:END:\n* card\n" *BOARD-NAME*)
     (orgtrello-buffer/board-name!)))
  (expect "this-is-the-user"
    (orgtrello-tests/with-org-buffer
     (format ":PROPERTIES:\n#+PROPERTY: %s this-is-the-user\n:END:\n* card\n" *ORGTRELLO-USER-ME*)
     (orgtrello-buffer/me!))))

(expectations
  (expect '(1 84)
    (orgtrello-tests/with-temp-buffer "* card       :some-tags:
:PROPERTIES:
:orgtrello-id: some-id
:END:
some-description
- [ ] checklist
  - [ ] item" (orgtrello-buffer/compute-card-header-and-description-region!))))

(expectations
  (expect '(8 24)
    (orgtrello-tests/with-temp-buffer "* card\n- [ ] checklist\n- [ ] another" (orgtrello-buffer/compute-checklist-header-region!))))

(expectations
  (expect '(8 24)
    (orgtrello-tests/with-temp-buffer "* card\n- [ ] checklist\n- [ ] item" (orgtrello-buffer/compute-checklist-region!)))
  (expect '(8 36)
    (orgtrello-tests/with-temp-buffer "* card\n- [ ] checklist\n  - [ ] item" (orgtrello-buffer/compute-checklist-region!)))
  (expect '(8 48)
    (orgtrello-tests/with-temp-buffer "* card\n- [ ] checklist\n  - [ ] item\n  - item 2\n" (orgtrello-buffer/compute-checklist-region!) -3))
  (expect '(8 48)
    (orgtrello-tests/with-temp-buffer "* card\n- [ ] checklist\n  - [ ] item\n  - item 2\n* another card" (orgtrello-buffer/compute-checklist-region!) -3)))

(expectations
  (expect '(17 33)
    (orgtrello-tests/with-temp-buffer "- [ ] checklist\n  - [ ] another" (orgtrello-buffer/compute-item-region!) 0)))

(expectations
  (expect "
* TODO some card name
  :PROPERTIES:
  :orgtrello-id: some-id
  :orgtrello-users: ardumont,dude
  :orgtrello-card-comments: ardumont: some comment
  :END:
some description
"
    (orgtrello-tests/with-temp-buffer-and-return-buffer-content
     "\n"
     (progn
       (setq *HMAP-USERS-ID-NAME* (orgtrello-hash/make-properties '(("ardumont-id" . "ardumont")
                                                                    ("dude-id" . "dude"))))
       (orgtrello-buffer/write-card-header! "some-id" (orgtrello-hash/make-properties `((:keyword . "TODO")
                                                                                              (:member-ids . "ardumont-id,dude-id")
                                                                                              (:comments . ,(list (orgtrello-hash/make-properties '((:comment-user . "ardumont")
                                                                                                                                                    (:comment-text . "some comment")))))
                                                                                              (:labels . ":red:green:")
                                                                                              (:desc . "some description")
                                                                                              (:level . ,*CARD-LEVEL*)
                                                                                              (:name . "some card name")))))
     0)))

(expectations
  (desc "orgtrello-buffer/write-entity! - card")
  (expect "\n* DONE some card name                                                   :red:green:\n  :PROPERTIES:\n  :orgtrello-id: some-card-id\n  :END:\n"
    (orgtrello-tests/with-temp-buffer-and-return-buffer-content
     "\n"
     (orgtrello-buffer/write-entity! "some-card-id " (orgtrello-hash/make-properties `((:keyword . "DONE")
                                                                                             (:tags . ":red:green:")
                                                                                             (:desc . "some description")
                                                                                             (:level . ,*CARD-LEVEL*)
                                                                                             (:name . "some card name"))))
     0)))

(expectations
  (desc "orgtrello-buffer/write-entity! - checklist")
  (expect "* some content\n- [-] some checklist name :PROPERTIES: {\"orgtrello-id\":\"some-checklist-id\"}\n"
    (orgtrello-tests/with-temp-buffer-and-return-buffer-content
     "* some content\n"
     (orgtrello-buffer/write-entity! "some-checklist-id" (orgtrello-hash/make-properties `((:keyword . "DONE")
                                                                                                 (:level . ,*CHECKLIST-LEVEL*)
                                                                                                 (:name . "some checklist name"))))
     0)))

(expectations
  (desc "orgtrello-buffer/write-entity! - item")
  (expect "* some content\n- [-] some checklist name :PROPERTIES: {\"orgtrello-id\":\"some-checklist-id\"}\n  - [X] some item name :PROPERTIES: {\"orgtrello-id\":\"some-item-id\"}\n"
    (orgtrello-tests/with-temp-buffer-and-return-buffer-content
     "* some content\n- [-] some checklist name :PROPERTIES: {\"orgtrello-id\":\"some-checklist-id\"}\n"
     (orgtrello-buffer/write-entity! "some-item-id" (orgtrello-hash/make-properties `((:keyword . "DONE")
                                                                                            (:level . ,*ITEM-LEVEL*)
                                                                                            (:name . "some item name"))))
     0)))

(expectations (desc "orgtrello-buffer/--csv-user-ids-to-csv-user-names")
              (expect "user0,user1,user2" (orgtrello-buffer/--csv-user-ids-to-csv-user-names "id0,id1,id2" (orgtrello-hash/make-properties '(("id0". "user0") ("id1". "user1") ("id2". "user2")))))
              (expect "user0,user1," (orgtrello-buffer/--csv-user-ids-to-csv-user-names "id0,id1,id2" (orgtrello-hash/make-properties '(("id0". "user0") ("id1". "user1")))))
              (expect "user0" (orgtrello-buffer/--csv-user-ids-to-csv-user-names "id0" (orgtrello-hash/make-properties '(("id0". "user0"))))))

(expectations (desc "orgtrello-buffer/--users-from")
              (expect '("a" "b" "c") (orgtrello-buffer/--users-from "a,b,c,,"))
              (expect '() (orgtrello-buffer/--users-from ",,,"))
              (expect '() (orgtrello-buffer/--users-from ""))
              (expect '() (orgtrello-buffer/--users-from nil)))

(expectations (desc "orgtrello-buffer/--users-to")
              (expect "" (orgtrello-buffer/--users-to nil))
              (expect "a,b,c," (orgtrello-buffer/--users-to '("a" "b" "c" ""))))
