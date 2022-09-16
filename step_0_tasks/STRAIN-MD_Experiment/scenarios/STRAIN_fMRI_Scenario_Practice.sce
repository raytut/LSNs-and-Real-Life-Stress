##################################################################################
#																											#
#									Stress and Resilience Study									#
#									---------------------------									#
#																											#
#											Practice Scenario											#		
#																											#
#																											#
##################################################################################
#--------------------------------------------------------------------------------#
# Header 	  																					
#--------------------------------------------------------------------------------#

scenario= "STRAIN_fMRI_Scenario_Practice.sce";
 
# Response Buttons
active_buttons = 5;									
button_codes = 1, 2, 3, 4, 5;									
response_matching = simple_matching;

# General Settings
default_font_size = 18;
default_font = "Times New Roman";
default_text_color = 250,250,250;
default_background_color = 125,125,125;
screen_width = 1024; screen_height = 768; 
screen_bit_depth = 32;

#--------------------------------------------------------------------------------#
# SDL Scripts 	  																					
#--------------------------------------------------------------------------------#

begin;
	TEMPLATE "STRAIN_fMRI_Definitions.tem";	
	
#--------------------------------------------------------------------------------#
# PCL Scripts 	  																					
#--------------------------------------------------------------------------------#

begin_pcl;

## Session and Subject Settings
int subjnr= 		999;
int session=1;
int run=1;

## Include Files:
include "STRAIN_fMRI_Subroutine.pcl";

## Practice Trial Count
odd_n_trials = 45;
ret_n_trials = 9;

## Include Everything Else
include "STRAIN_fMRI_Task_Oddball.pcl";		
include "STRAIN_fMRI_Task_Nback.pcl";
include "STRAIN_fMRI_Task_Retrieval.pcl";
	
#--------------------------------------------------------------------------------#
# Practice Tasks 	  																					
#--------------------------------------------------------------------------------#	

## Instructions (set false to present)
bool odd_instruction = true;
bool nback_instruction = true;
bool ret_instruction = true;


## Present Main Instructions
practice_instructions_1.present();
waitforbuttonpress();

## Present Each Task With No Instruciton 
loop int order_loop; int i=1; int k; until order_loop>=(trial_order.count())
	begin

		if trial_order[i]==1 then
			if odd_instruction==true then
				odd_instructions_1.present ();
				waitforbuttonpress ();
				odd_instruction=false;
			end;
			circle.present();
			wait (6000);
			odd_subroutine ();
			i=i+1;
			
		elseif trial_order[i]==2 then
			if nback_instruction==true then
				nback_instructions_1.present ();
				waitforbuttonpress ();
				nback_instruction=false;
			end;
			square.present();
			wait (6000);
			nback_subroutine (1);
			i=i+1;
			
		elseif trial_order[i]==3 then
			if ret_instruction==true then
				ret_instruction_1.present();
				waitforbuttonpress ();
				ret_instruction_2.present();
				waitforbuttonpress ();
				ret_instruction=false;
			end;
			triangle.present();
			wait (6000);
			ret_subroutine (1);
			i= i+1	
	end;
	order_loop= order_loop +1;
end;


## Thank You Text
pic_bedankt.present();
waitforbuttonpress ();
	