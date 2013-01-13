# Emacs Java Support

## Depreciation

**This package is now depreciated and unmaintained.** It has been
split into two separate, more focused packages.

The java-docs portion has been replaced by the more powerful
[javadoc-lookup](https://github.com/skeeto/javadoc-lookup). This one
will fetch the documentation *for* you. It's also focused on
supporting JVM-based languages more generally.

The java-mode-plus portion had been replaced by
[ant-project-mode](https://github.com/skeeto/ant-project-mode). This
is mostly a name change, with future changes focused more tightly on
supporting Ant-based Java projects.

## Overview

See the header comments in each file for full documentation. The
recommended usage is in java-mode-plus.el.

To install drop these in your load-path somewhere and require them
(after enabling ido-mode, if you use ido-mode),

```el
(require 'java-mode-plus)
(require 'java-docs)
```

To use java-docs you'll need to tell it where to find some
documentation. For example,

```el
(java-docs "/usr/share/doc/openjdk-6-jdk/api")
```

The snippets directory contains some YASnippets that hook into
java-docs class completing reads.
