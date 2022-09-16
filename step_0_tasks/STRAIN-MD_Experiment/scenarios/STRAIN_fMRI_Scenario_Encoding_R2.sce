##################################################################################
#																											#
#										Stress and Resilience Study								#
#										---------------------------								#
#																											#
#											 Encoding Scenario										#		
#																											#
#																											#
##################################################################################
#--------------------------------------------------------------------------------#
# Header 	  																					
#--------------------------------------------------------------------------------#

scenario = "STRAIN_fMRI_Encoding_R1.sce";

## Response Buttons
active_buttons = 5;									
button_codes = 1, 2, 3, 4, 5;							
response_matching = simple_matching;		
		

## Basic settings
default_font_size = 20;
default_font = "Times New Roman";
default_text_color = 255,255,255;
default_background_color = 125,125,125;


## Screen settings
screen_width = 1920;
screen_height = 1080;
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

## Subject Settings
int subjnr=1;
if int(logfile.subject()) > 0  then
	subjnr = int(logfile.subject());
end;
int itrial_order= 1; #Irrelevant for Enc

## Asks For Session
int session;
sub GetKeyboardInput(string sInpStr)
begin
	string sKeyboardInput;
	t_Text1.set_caption(sInpStr);
	t_Text1.redraw();
	system_keyboard.set_case_mode(3);
	sKeyboardInput=system_keyboard.get_input(p_Text, t_Text2);
	session = int(sKeyboardInput);
end;	
GetKeyboardInput("Session Number:");

## Run
int run= 2;

## Include Files:
include "STRAIN_fMRI_Subroutine.pcl";
include "STRAIN_fMRI_Task_Encoding.pcl";
MakeOutputFile(sENCLogFileDir);


#--------------------------------------------------------------------------------#
# Encoding Task  																					
#--------------------------------------------------------------------------------#

begin
	
	# Begin Experiment
	iExperimentOn = clock.time();
	enc_subroutine (1);
	iExperimentOff=clock.time();
	WriteToOutputFile(sENCLogFileDir);
	
	# End Experiment
	enc_endroutine (1);
	wait (5000);
end;



