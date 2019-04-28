(ert-deftest elpy-project-root-should-return-user-set-version ()
  (elpy-testcase ()
    (let ((elpy-project-root "/tmp"))
      (should (f-equal? (elpy-project-root)
                        "/tmp")))))

(ert-deftest elpy-project-root-should-call-find-root-if-not-set ()
  (elpy-testcase ()
    (let ((elpy-project-root nil)
          (elpy-project-root-finder-functions '((lambda ()
                                                  "/tmp"))))
      (should (f-equal? (elpy-project-root)
                        "/tmp")))))
