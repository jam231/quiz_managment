# encoding: UTF-8
class LimboController < ApplicationController
		include LimboHelper

		before_filter :can_access_limbo?

		helper_method :active?

		def index
			@limbo = GrupaQuizowa.Limbo
			quizzes
		end

		def info
			@quiz = Quiz.find(params[:id_quizu])
			render :template => 'limbo/index', :locals => {:what => 'info'}
		end

		def quizzes
			@limbo = GrupaQuizowa.Limbo
			@quizzes = @limbo.quizzes.all
			render :template => 'limbo/index', :locals => {:what => 'quizzes'}
		end

		def moderators
			@limbo = GrupaQuizowa.Limbo
			@moderators = Uzytkownik.scoped.select {|uzytkownik| uzytkownik.superuser? and not uzytkownik.limbo?}
			render :template => 'limbo/index', :locals => {:what => 'moderators'}
		end

		# GET
		def quiz_ownership
			@limbo = GrupaQuizowa.Limbo
			@quiz = Quiz.find(params[:id_quizu])
			@current_owner = Uzytkownik.find(@quiz.id_wlasciciela)
			@available_users = Uzytkownik.scoped.select {|uzytkownik| not (uzytkownik.superuser? or uzytkownik.limbo? or uzytkownik == @current_owner) }
			render :template => 'limbo/index', :locals => {:what => 'quiz_ownership'}
		end
		# POST
		def transfer_quiz_ownership
			logger.debug "Nowym właścieielem quizu #{params[:id_quizu]} zostaje uzytkownik o id = #{params[:new_owner_id]}"
			quiz = Quiz.find(params[:id_quizu])
			quiz.id_wlasciciela = params[:new_owner_id]
			quiz.save
			redirect_to limbo_transfer_quiz_ownership_url, :notice => "Zapisano zmiany."
		end

		# DELETE
		def delete_user_answers
			redirect_to grupa_limbo_url, :alert => 'Not implemented yet.'
		end

		# GET
		def quiz_group_transfer_form
			@limbo = GrupaQuizowa.Limbo
			@groups = GrupaQuizowa.scoped.select {|grupa| not grupa.limbo?}
			render :template => 'limbo/index', :locals => {:what => 'quiz_group_transfer_form'}
		end

		protected

		def active?(rendered, question)
			case question
				when :quizzes
					rendered == 'quizzes'
				when :transfer_quiz
					rendered == 'quiz_group_transfer_form'
				when :delete_user_answers
					rendered == 'delete_user_answers'
				when :transfer_ownership
					rendered == 'transfer_ownership'
				when :moderators
					rendered == 'moderators'
				else
					false
			end
		end
	end
