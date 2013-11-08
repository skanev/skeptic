require 'spec_helper'

module Skeptic
  module Rules
    describe Naming do
      it_behaves_like 'Rule' do
        subject { Naming.new(true) }
      end

      describe 'detecting bad names' do
        it 'can find bad module names' do
          code = <<-RUBY
            module Uncle_bobbie
              def aunt
              end
            end
          RUBY

          expect_bad_names_of(:module, code, 1)
        end

        it 'can find bad class names' do
          code = <<-RUBY
            class Grandpa_dude
            end
          RUBY

          expect_bad_names_of(:class, code, 1)
        end

        it 'can find bad method names' do
          code = <<-RUBY
            def WEIRD_GirL
            end

            def ok_girl
            end

            def kiFLagirl
            end

            class A
              def dEF
              end
            end
          RUBY

          expect_bad_names_of(:def, code, 3)
        end

        it 'can find bad symbol names' do
          code = "[:class, :B_E, :okGirl, :function, :e_FL, :symbol, :Module]"

          expect_bad_names_of(:symbol, code, 4)
        end

        it 'can find bad variable names' do
          expect_bad_names_of(:@ident, "aWeirdVar = 2", 1)
        end

        it 'can find bad instance variable names' do
          code = <<-RUBY
            class A
              @kDlE = 2
            end
          RUBY

          expect_bad_names_of(:@ivar, code, 1)
        end

        it 'can find bad class variable names' do
          code = <<-RUBY
            class B
              @@beaTlEs = 4
            end
          RUBY

          expect_bad_names_of(:@cvar, code, 1)
        end

        it 'doesn\'t give false positives' do
          code = <<-RUBY
            class CcC
              def d_d
                2
              end

              f_f = :s_d
              @k_l = 4
              @@l_m = 5
            end

            module EeE
            end
          RUBY

          analyze(code).violations.count.should eq 0
        end

        it 'can find different kinds of bad names' do
          code = <<-RUBY
            sym = :Dl
            module Wk_E
            end

            class Lf_s
            end
          RUBY

          expect_bad_names_of(:symbol, code, 1)
          expect_bad_names_of(:class, code, 1)
          expect_bad_names_of(:module, code, 1)
        end
      end

      describe 'reporting' do
        it 'can tell what kind of name is bad' do
          analyzer = analyze <<-RUBY
            class Lala_lala
              def HiThere
                :laLa
              end
            end
          RUBY

          analyzer.violations.should include 'class named Lala_lala on line 1 is not CamelCase'
          analyzer.violations.should include 'method named HiThere on line 2 is not snake_case'
        end

        it 'can tell on which line is the bad name' do
          analyzer = analyze <<-RUBY
            class Zebra
              def lalaLala
                @a = 0
                kLe = 4
              end
            end
          RUBY

          analyzer.violations[1].should include 'on line 4'
          analyzer.violations[0].should include 'on line 2'
        end

        it 'can tell what writing practice is expected for a type of name' do
          analyzer = analyze('fL = @iVar')

          analyzer.violations[0].should include 'snake_case'
          analyzer.violations[1].should include 'snake_case'
        end
      end

      def expect_bad_names_of(type, code, count)
        analyze(code)
          .instance_variable_get("@violations").map(&:first)
          .select { |violation_type| type == violation_type }
          .count.should eq count
      end

      def analyze(code)
        apply_rule(Naming, true, code)
      end
    end
  end
end
