SUBDIRS := static \
	   shared

STATIC_MMAKE_OBJ_PREFIX := static/
SHARED_MMAKE_OBJ_PREFIX := shared/

TEST_APPS := zfsink zfpingpong zftcppingpong

# build static as well as shared library version of each app
STATIC_TARGETS := $(TEST_APPS:%=static/$(AppPattern))
SHARED_TARGETS := $(TEST_APPS:%=shared/$(AppPattern))

TARGETS := $(SHARED_TARGETS) $(STATIC_TARGETS)

# We would use C11, but we need to support RHEL6.  C99 is good enough for the
# test apps.
MMAKE_CFLAGS += -std=gnu99

$(SHARED_TARGETS): MMAKE_LIBS     := $(LINK_ZF_LIB)
$(SHARED_TARGETS): MMAKE_LIB_DEPS := $(ZF_LIB_DEPEND)
$(SHARED_TARGETS): $(ZF_LIB_DEPEND)

$(STATIC_TARGETS): MMAKE_LIBS := $(LINK_ZF_STATIC_LIB)
$(STATIC_TARGETS): MMAKE_CFLAGS += -D__USING_ZF_STATIC_LIB__
$(STATIC_TARGETS): MMAKE_LIB_DEPS := $(ZF_STATIC_LIB_DEPEND)
$(STATIC_TARGETS): $(ZF_STATIC_LIB_DEPEND)

$(SHARED_MMAKE_OBJ_PREFIX)%.o : %.c
		$(MMakeCompileC)

$(STATIC_MMAKE_OBJ_PREFIX)%.o : %.c
		$(MMakeCompileC)

$(SHARED_TARGETS): shared/%: $(SHARED_MMAKE_OBJ_PREFIX)%.o
$(STATIC_TARGETS): static/%: $(STATIC_MMAKE_OBJ_PREFIX)%.o

$(TARGETS):
		@(libs="$(MMAKE_LIBS)"; $(MMakeLinkCApp))

all: $(TARGETS)
	+@$(MakeSubdirs)
clean:
	@$(MakeClean)