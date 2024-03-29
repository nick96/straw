# frozen_string_literal: true

require_relative "./test_helper"

class TestStraw < Minitest::Test
    def test_it_handles_method_overloads
        dummy = Class
          .new do
              extend(Straw)

              overload def test_method(first_arg)
                  1
              end

              overload def test_method(first_arg, second_arg)
                  2
              end

              overload def test_method(first_arg, second_arg, third_arg)
                  3
              end
          end
          .new

        assert_equal(dummy.test_method("test"), 1)
        assert_equal(dummy.test_method("test", "test"), 2)
        assert_equal(dummy.test_method("test", "test", "test"), 3)
        assert_raises(Straw::NoMatchingOverloadError) {
            dummy.test_method("test", "test", "test", "test")
        }
    end

    def test_it_handles_function_overloads
        dummy = Module.new do
            extend(Straw)

            overload def self.test(first_arg)
                1
            end

            overload def self.test(first_arg, second_arg)
                2
            end

            overload def self.test(first_arg, second_arg, third_arg)
                3
            end
        end

        assert_equal(dummy.test("test"), 1)
        assert_equal(dummy.test("test", "test"), 2)
        assert_equal(dummy.test("test", "test", "test"), 3)
        assert_raises(Straw::NoMatchingOverloadError) {
            dummy.test("test", "test", "test", "test")
        }
    end
end
