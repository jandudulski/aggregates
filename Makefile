test_aggregate_root:
	@bundle exec ruby -Itest -Iaggregate_root -rproject_management test/issue_test.rb

mutate_aggregate_root:
	@bundle exec mutant --include test \
		--include aggregate_root \
		--require project_management \
		--use minitest "ProjectManagement*"

test_query_based:
	@bundle exec ruby -Itest -Iquery_based -rproject_management test/issue_test.rb

mutate_query_based:
	@bundle exec mutant --include test \
		--include query_based \
		--require project_management \
		--use minitest "ProjectManagement*"

test_extracted_state:
	@bundle exec ruby -Itest -Iextracted_state -rproject_management test/issue_test.rb

mutate_extracted_state:
	@bundle exec mutant --include test \
		--include extracted_state \
		--require project_management \
		--use minitest "ProjectManagement*"

test_functional:
	@bundle exec ruby -Itest -Ifunctional_aggregate -rproject_management test/issue_test.rb

mutate_functional:
	@bundle exec mutant --include test \
		--include functional_aggregate \
		--require project_management \
		--use minitest "ProjectManagement*"

test_polymorphic:
	@bundle exec ruby -Itest -Ipolymorphic -rproject_management test/issue_test.rb

mutate_polymorphic:
	@bundle exec mutant --include test \
		--include polymorphic \
		--require project_management \
		--use minitest "ProjectManagement*"

test_yield_based:
	@bundle exec ruby -Itest -Iyield_based -rproject_management test/issue_test.rb

mutate_yield_based:
	@bundle exec mutant --include test \
		--include yield_based \
		--require project_management \
		--use minitest "ProjectManagement*"

test: test_aggregate_root test_query_based test_extracted_state test_functional test_polymorphic test_yield_based

mutate: mutate_aggregate_root mutate_query_based mutate_extracted_state mutate_functional mutate_polymorphic mutate_yield_based

.PHONY: test mutate