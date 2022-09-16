##################################################################################
#																											#
#								Behavioral session 1													#
#																											#
##################################################################################


#--------------------------------------------------------------------------------#
# Header                                                                                        
#--------------------------------------------------------------------------------#

scenario = "STRAIN_BEH_Scenario_s1.sce";

## Response Buttons
active_buttons = 8;           
button_codes = 1,2,3,4,5,6,7,8;       
response_matching = simple_matching;        

## Basic settings
default_font_size = 28;
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
TEMPLATE "STRAIN_BEH_Definitions.tem";  

#--------------------------------------------------------------------------------#
# PCL Scripts                                                                                       
#--------------------------------------------------------------------------------#

begin_pcl;

## Include Files:
int session =1;

include "STRAIN_BEH_Subroutines.pcl";
include "STRAIN_BEH_Task_NBack.pcl";
include "STRAIN_BEH_Task_Matrices.pcl";
include "STRAIN_BEH_Task_WordList.pcl";

MakeOutputFile(sBehLog);
MakeOutputFile(sWordRecall);


#--------------------------------------------------------------------------------#
# Encoding Task  																					
#--------------------------------------------------------------------------------#

# Instructions for the word encoding session
showtext("Om te beginnen ga je nu een serie woorden zien,\nmet tussendoor telkens een kruis.\nWe vragen je deze woorden goed te onthouden.\n Straks zal getest worden welke woorden je nog kent.\n \n Let op: wanneer een woord rood gekleurd is,\n is het de bedoeling dat je het cijfer '2' indrukt.\nHet is dus belangrijk dat je je aandacht er bij houdt.\n \nAls alles duidelijk is, druk dan op '2' om te beginnen.");
WaitForSpecButtonpress(2);
fixationcross.present();
wait (1200);

# Start of the word encoding session
iTrial=1;
trial_resp_on.present();
wordenc_sub();
showtext("Dit is het einde van deze taak.\n\nJe krijgt nu een pauze van 1 minuut\nvoordat de volgende taak begint.");
wait (60000);

#--------------------------------------------------------------------------------#
# N-Back task																				
#--------------------------------------------------------------------------------#

# Instructions for the n-back task:
trial_resp_on.present();
nback_instruction.present();
WaitForSpecButtonpress(3);
fixationcross.present();
wait (1000);

iTrial=2;

# Loop over n-back 10 times, with breaks of 15 sec
loop int nbackcount=1 until nbackcount > 10
begin
	nback_subroutine(1);
	showtext("Je krijgt nu 15 seconden rust");
	wait (15000);
	nbackcount = nbackcount + 1;
end;

showtext("Dit is het einde van deze taak.\n\nJe krijgt nu een pauze van 1 minuut\nvoordat de volgende taak begint.");
wait (60000);

#--------------------------------------------------------------------------------#
# Matrices Instructions + Practice																				
#--------------------------------------------------------------------------------#

## Practice Trials
trial_resp_on.present();
matrix_instruction_1.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (800);

matrix_instruction_2.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (800);

matrix_example_1.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (800);

matrix_example_2.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (800);

matrix_example_3.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (800);

matrix_instruction_6.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (4000);

## Task Start
iTrial=3;
trial_resp_on.present();
matrices_sub();


showtext("Dit is het einde van deze taak.\n\nJe krijgt nu een pauze van 1 minuut\nvoordat de volgende taak begint.");
wait (60000);


#--------------------------------------------------------------------------------#
# Word free recall																		
#--------------------------------------------------------------------------------#

trial_resp_on.present();
freerecall_instruction.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (1200);

trial_resp_on.present();
FreeRecall_sub();
fixationcross.present();
wait (500);
showtext("Dit is het einde van deze taak.\n\nJe krijgt nu een pauze van 1 minuut\nvoordat de volgende taak begint.");
wait (60000);

#--------------------------------------------------------------------------------#
# Word recognition recall																		
#--------------------------------------------------------------------------------#

# Instructions for the word retrieval task
trial_resp_on.present();
wordret_instruction.present();
WaitForSpecButtonpress(2);
fixationcross.present();
wait (1000);

# Start of the word retrieval task
iTrial=4;
trial_resp_on.present();
wordret_sub();
showtext("Dit is het einde van dit experiment.\nDankjewel voor je deelname!");
wait (4000); 
