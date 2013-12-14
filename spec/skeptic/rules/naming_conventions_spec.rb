require 'spec_helper'

module Skeptic
  module Rules
    describe NamingConventions do
      it_behaves_like 'Rule' do
        subject { NamingConventions.new(true) }
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

        it 'can find bad const names' do
          expect_bad_names_of(:@const, "KL = 2", 0)
        end

        it 'can make a difference between class and const' do
          expect_bad_names_of(:@const, "class A;end", 0)
        end

        it 'can find bad names in function definitions' do
          expect_bad_names_of(:@ident, "def a(eW, fF = 2, *gK, &bN);end", 4)
        end

        it 'can find bad names in singleton method definitions' do
          expect_bad_names_of(:defs, "def s.lF;end", 1)
        end

        it "doesn't check names which aren't introduced by the program" do
          #expect_no_bad_names "include Ens"
          expect_no_bad_names "f = kLeE"
          expect_no_bad_names "@w = KD_E"
          expect_no_bad_names "keeper.whatTheFuck"
          expect_no_bad_names "d = Ens"
        end

        it "doesn't give false positives" do
          code = <<-RUBY
            class CcC
              def d_d?
                2
              end

              def s!
                2
              end

              f_f = :s_d
              @k_l = 4
              @@l_m = 5
            end

            module EeE
            end
          RUBY

          expect_no_bad_names code
        end

        it 'can find different kinds of bad names' do
          code = <<-RUBY
            sym = :Dl
            module Wk_E
            end

            class Lf_s
            end
          RUBY

          expect_bad_names_of(:class, code, 1)
          expect_bad_names_of(:module, code, 1)
        end
      end

      describe 'reporting' do
        it 'can tell what kind of name is bad' do
          analyzer = analyze <<-RUBY
            class Lala_lala
              def HiThere
                'e'
                :llLz
              end
            end
          RUBY

          analyzer.violations.should include 'class named Lala_lala on line 1 is not in CamelCase'
          analyzer.violations.should include 'method named HiThere on line 2 is not in snake_case'
          analyzer.violations.should include 'symbol named llLz on line 4 is not in snake_case'
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

        it 'can report different kind of naming mistakes' do
          analyzer = analyze('fL = 2; @iVar = 2; :sWd; @@lE = [nil]')

          analyzer.violations[0].should include 'local variable'
          analyzer.violations[1].should include 'instance variable'
          analyzer.violations[2].should include 'symbol'
          analyzer.violations[3].should include 'class variable'
        end
      end

      def expect_bad_names_of(type, code, count)
        analyze(code).
          instance_variable_get("@violations").map(&:first).
          select { |violation_type| type == violation_type }.
          count.should eq count
      end

      def expect_no_bad_names(code)
        analyze(code).
          instance_variable_get("@violations").should be_empty
      end

      def analyze(code)
        apply_rule(NamingConventions, true, code)
      end
    end
  end
end
