#!/usr/bin/perl
use strict;
# use warnings FATAL => 'all';
use Mojo::File;
use FindBin;
use File::Spec;
use YAML::XS;
use Data::Dumper;
no warnings 'recursion';
use 5.010001;

sub mes {
    print $_. "\n";
}

if ($self->BaseJob() == $self->Job_Alchemist()) {
    if ($self->JobLevel() < 40) {
        mes "[Pisruik]";
        mes "^333333*Cough cough*^000000";
        mes "Damn, if only I had";
        mes "a little more money";
        mes "to buy some medicine.";
        mes "I should have stayed";
        mes "home today, but...";
        $self->close;
    }
    if ($self->ALCHE_SK() == 0) {
        mes "[Pisruik]";
        mes "^333333*Cough cough*^000000";
        mes "Ugh, there's nothing";
        mes "worse than working when";
        mes "you're supposed to be resting.";
        mes "H-hey! Um, what are you doing?";
        set $self->ALCHE_SK(),1;
        $self->next;
        mes "[Pisruik]";
        mes "Q-quit looking at";
        mes "my test results right";
        mes "this inst--oh. Wait.";
        mes "You're not one of the";
        mes "researchers here. Huh.";
        $self->next;
        mes "[Pisruik]";
        mes "Uh... Don't you have";
        mes "anything better to do";
        mes "than to breathe down my";
        mes "back? I'm trying to finish";
        mes "something here! Oh, never";
        mes "mind, I'm just cranky...";
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 1) {
        mes "[Pisruik]";
        mes "You again? You don't seem";
        mes "to be doing any research here.";
        mes "Is there something you need?";
        mes "Though, I'm afraid I can't be";
        mes "of very much help to you.";
        $self->next;
        if ($self->select("What are you working on?:I don't need anything, thanks.") == 1) {
            mes "[Pisruik]";
            mes "Well, I'm not sure if I can";
            mes "give you all of the details.";
            mes "You see, everyone here is";
            mes "a researcher that can't afford";
            mes "to rent a lab for himself. So we all ended up sharing this one.";
            $self->next;
            mes "[Pisruik]";
            mes "Even though we all pitched";
            mes "in to rent this lab, we're all";
            mes "getting pretty desperate. In";
            mes "fact, a few of us have even";
            mes "stolen work from each other.";
            mes "That's pretty pathetic, huh?";
            $self->next;
            mes "[Pisruik]";
            mes "I guess that's what happens";
            mes "when you're poor and don't";
            mes "have a day job. Things are";
            mes "so bad right now, I can't even";
            mes "afford to get new materials!";
            mes "What can I possibly do?";
            $self->next;
            mes "[Pisruik]";
            mes "Ah, I've got it! You're";
            mes "an adventurer, right?";
            mes "If you're still curious about";
            mes "my research, I'll tell you more";
            mes "about it if you help me out by";
            mes "gathering some supplies for me.";
            $self->next;
            mes "[Pisruik]";
            mes "I guess it couldn't do";
            mes "much harm if you knew what";
            mes "I was working on, anyway.";
            mes "I mean, we'd have to be working";
            mes "on the same project for you to";
            mes "benefit. So, what's your name?";
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "I am called "+ strcharinfo(0) +".";
            $self->next;
            set $self->ALCHE_SK(),2;
            mes "[Pisruik]";
            mes "Ah, "+ strcharinfo(0) +".";
            mes "Would you please bring";
            mes "^6600005 Yellow Gemstones^000000,";
            mes "^6600004 Empty Potion Bottles^000000,";
            mes "^66000010 Hearts of Mermaids^000000,";
            mes "and ^66000010 Moth Dust^000000?";
            $self->close;
        }
        mes "[Pisruik]";
        mes "If you came here to buy";
        mes "Potion Manuals or something";
        mes "like that, you've come to the";
        mes "wrong guy. Everything you see";
        mes "here is for the completion";
        mes "of a personal project.";
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 2) {
        mes "[Pisruik]";
        mes "Great you're back!";
        mes "Let's see, you were";
        mes "supposed to bring me";
        mes "4 Empty Potion Bottles...";
        mes "And... And... What else";
        mes "did I ask you to get?";
        $self->next;
        given($self->select("5 Yellow Gemstones:5 Blue Gemstones:5 Red Gemstones")) {
            when (1) {}
            mes "[Pisruik]";
            mes "Right, right!";
            mes "5 Yellow Gemstones.";
            mes "That's what I needed.";
            mes "I'm sure there was more,";
            mes "but what I can't recall exactly...";
            $self->next;
            if ($self->select("10 Hearts of Mermaid:10 Large Jellopies") == 1) {
                mes "[Pisruik]";
                mes "Of course!";
                mes "10 Hearts of Mermaid!";
                mes "How could I forget that?";
                mes "And then, the last thing";
                mes "I asked you for was, um...";
                $self->next;
                if ($self->select("10 Frill:10 Moth Dust") == 1) {
                    mes "[Pisruik]";
                    mes "No, that can't have";
                    mes "been it. I already have";
                    mes "plenty of Frills. Hmmm...";
                    mes "What am I missing now?";
                    $self->close;
                }
                mes "[Pisruik]";
                mes "Right. I was just";
                mes "about to say that.";
                mes "So did you remember";
                mes "to bring me everything?";
                $self->next;
                if ($self->select("No.:Yes!") == 1) {
                    if ($self->rand(1,5) == 1) {
                        mes "[Pisruik]";
                        mes "You didn't...?";
                        mes "Oh, just admit it.";
                        mes "You don't want to";
                        mes "do this for me, right?";
                        mes "Don't go wasting your";
                        mes "time just for my sake.";
                        $self->close;
                    }
                    mes "[Pisruik]";
                    mes "Not yet, huh?";
                    mes "Though I hope you can";
                    mes "bring me that stuff as";
                    mes "soon as possible, you";
                    mes "don't have to do it, you";
                    mes "know. Yeah, no big deal.";
                    $self->close;
                }
                mes "[Pisruik]";
                mes "Really now?";
                mes "Well, let me check";
                mes "what you brought to";
                mes "make sure you didn't";
                mes "forget anything. Hm...";
                $self->next;
                if ($self->countitem(715) > 4 && $self->countitem(1093) > 3 && $self->countitem(950) > 9 && $self->countitem(1057) > 9) {
                    $self->delitem(715,5);
                    $self->delitem(1093,4);
                    $self->delitem(950,10);
                    $self->delitem(1057,10);
                    set $self->ALCHE_SK(),3;
                    mes "[Pisruik]";
                    mes "Great, it looks like";
                    mes "everything is here.";
                    mes "Alright, let me take";
                    mes "those. Now, guess what";
                    mes "I'll be making with the";
                    mes "materials you've brought.";
                    $self->next;
                    given($self->select("Medicine?:Bomb?")) {
                        when (1) {}
                        set $self->ALCHE_SK(),4;
                        mes "[Pisruik]";
                        mes "Hahahah, that's right!";
                        mes "I'm working on making";
                        mes "a new form of medicine.";
                        break;
                        when (2) {}
                        set $self->ALCHE_SK(),4;
                        mes "[Pisruik]";
                        mes "A bomb? Do I look like";
                        mes "a nutcase to you? No, no...";
                        mes "I'm developing a new form of";
                        mes "medicine. Sure, bombs make";
                        mes "good money, but where would";
                        mes "I test them? Here? No way!";
                        break;
                    }
                    $self->next;
                    mes "[Pisruik]";
                    mes "Anyway, this medicine";
                    mes "reacts with the human body's";
                    mes "digestive enzymes to initiate";
                    mes "temporary metabolic changes";
                    mes "that artificially stop heat";
                    mes "absorption into the body.";
                    $self->next;
                    mes "[Pisruik]";
                    mes "The actual effect of this";
                    mes "medicine is that it greatly";
                    mes "increases the body's resistance";
                    mes "to most forms of heat! However,";
                    mes "it will also reduce resistance";
                    mes "to cold as a side effect.";
                    $self->next;
                    mes "[Pisruik]";
                    mes "I know my medicine sounds";
                    mes "a little weird, but think of";
                    mes "the applications! If used in";
                    mes "the right situations, this";
                    mes "medicine may be quite handy.";
                    $self->next;
                    mes "[Pisruik]";
                    mes "Ah, seeing as you're still";
                    mes "here, would you mind helping";
                    mes "me again? I need about, hmm,";
                    mes "20 Maneater Blossoms. If you";
                    mes "could bring them to me, it'd";
                    mes "really help me out a lot.";
                    $self->next;
                    given($self->select("Nope, I'm too busy!:Sure, I'll help you.:What's in it for me?")) {
                        when (1) {}
                        set $self->ALCHE_SK(),5;
                        mes "[Pisruik]";
                        mes "I guess I'll have to gather";
                        mes "those on my own. Alright, well,";
                        mes "seeing as we've both gotten";
                        mes "what we wanted, I'll suppose";
                        mes "your business with me is done.";
                        $self->close;
                        when (2) {}
                        set $self->ALCHE_SK(),6;
                        mes "[Pisruik]";
                        mes "Thanks, I really";
                        mes "appreciate it. While";
                        mes "I'm waiting for you,";
                        mes "I can start boiling";
                        mes "the Clover extract.";
                        $self->next;
                        $self->select("Clover extract? What's that for?");
                        mes "[Pisruik]";
                        mes "Well, I need the Clover";
                        mes "extract for a compound";
                        mes "that I'm going to make with";
                        mes "the Maneater Blossoms. I'm";
                        mes "kind of weak, so I try not to";
                        mes "travel too far when I can.";
                        $self->next;
                        mes "[Pisruik]";
                        mes "Yeah, ever since I was";
                        mes "little, I've had a weak";
                        mes "heart and bad eyesight.";
                        mes "The doctor tells me to avoid";
                        mes "stress and hard work, but";
                        mes "researching is my life.";
                        if ($self->Sex() == $self->SEX_FEMALE()) {
                            $self->next;
                            mes "[Pisruik]";
                            mes "I wonder...";
                            mes "If you understand";
                            mes "the way I feel, how";
                            mes "much I've had to sacrifice";
                            mes "for my dream. Heh, anyway...";
                        }
                        $self->next;
                        mes "[Pisruik]";
                        mes "I hope you understand that";
                        mes "it's too dangerous for me to";
                        mes "gather Maneater Blossoms on";
                        mes "my own, so if I'm going to get";
                        mes "as much help as I can. Thanks";
                        mes "again for being cooperative.";
                        $self->close;
                        when (3) {}
                        mes "[Pisruik]";
                        mes "Ha ha ha ha!";
                        mes "That's real business";
                        mes "like of you! Alright,";
                        mes "I may be poor, but if";
                        mes "you help me, I'll give you";
                        mes "the results of my research.";
                        $self->next;
                        if ($self->select("Nah, I'm too busy.:Alright, I'll help you.") == 1) {
                            set $self->ALCHE_SK(),5;
                            mes "[Pisruik]";
                            mes "I guess I'll have to gather";
                            mes "those on my own. Alright, well,";
                            mes "seeing as we've both gotten";
                            mes "what we wanted, I'll suppose";
                            mes "your business with me is done.";
                            $self->close;
                        }
                        set $self->ALCHE_SK(),6;
                        mes "[Pisruik]";
                        mes "Thanks, I really";
                        mes "appreciate it. While";
                        mes "I'm waiting for you,";
                        mes "I can start boiling";
                        mes "the Clover extract.";
                        $self->next;
                        $self->select("Clover extract? What's that for?");
                        mes "[Pisruik]";
                        mes "Well, I need the Clover";
                        mes "extract for a compound";
                        mes "that I'm going to make with";
                        mes "the Maneater Blossoms. I'm";
                        mes "kind of weak, so I try not to";
                        mes "travel too far when I can.";
                        $self->next;
                        mes "[Pisruik]";
                        mes "Yeah, ever since I was";
                        mes "little, I've had a weak";
                        mes "heart and bad eyesight.";
                        mes "The doctor tells me to avoid";
                        mes "stress and hard work, but";
                        mes "researching is my life.";
                        if ($self->Sex() == $self->SEX_FEMALE()) {
                            $self->next;
                            mes "[Pisruik]";
                            mes "I wonder...";
                            mes "If you understand";
                            mes "the way I feel, how";
                            mes "much I've had to sacrifice";
                            mes "for my dream. Heh, anyway...";
                        }
                        $self->next;
                        mes "[Pisruik]";
                        mes "I hope you understand that";
                        mes "it's too dangerous for me to";
                        mes "gather Maneater Blossoms on";
                        mes "my own, so if I'm going to get";
                        mes "as much help as I can. Thanks";
                        mes "again for being cooperative.";
                        $self->close;
                    }
                }
                elsif ($self->countitem(715) == 0 && $self->countitem(1093) == 0 && $self->countitem(950) == 0 && $self->countitem(1057) == 0) {
                    mes "[Pisruik]";
                    mes "So you knew what";
                    mes "you had to bring, came";
                    mes "to remind me what I had";
                    mes "forgotten, but didn't bring";
                    mes "anything? Weird. Ah well.";
                    mes "Come with the stuff next time.";
                    $self->close;
                }
                else {
                    mes "[Pisruik]";
                    mes "Oh, this isn't good, some";
                    mes "of the items I asked for are";
                    mes "missing. I'm sorry, but Alchemy";
                    mes "gets dangerously unpredictable";
                    mes "when things aren't used in just";
                    mes "the right amounts. Hmmm...";
                    $self->next;
                    mes "[Pisruik]";
                    mes "Well, I can afford to";
                    mes "push my deadlines back";
                    mes "if you promise to return";
                    mes "with the materials I need";
                    mes "as soon as you possibly can.";
                    $self->close;
                }
            }
            mes "[Pisruik]";
            mes "Large Jellopy?";
            mes "Yes, Large--no.";
            mes "Wait, that doesn't";
            mes "sound right at all.";
            mes "No, it was something";
            mes "else I need you to get.";
            $self->close;
            when (2) {}
            mes "[Pisruik]";
            mes "Blue Gemstones...?";
            mes "No, that was for the";
            mes "potion that increases";
            mes "tolerance to the Water";
            mes "property, I think. What's";
            mes "wrong with my memory?!";
            $self->close;
            when (3) {}
            mes "[Pisruik]";
            mes "Red Gemstones...?";
            mes "No, that was for the";
            mes "potion that increases";
            mes "tolerance to the Earth";
            mes "property, I think. What's";
            mes "wrong with my memory?!";
            $self->close;
        }
    }
    elsif ($self->ALCHE_SK() == 3) {
        mes "[Pisruik]";
        mes "Why did you just leave?";
        mes "You didn't even let me";
        mes "finish talking! Oh well,";
        mes "maybe it's not your fault.";
        mes "Anyway, just so you know,";
        mes "I'm developing a new medicine.";
        set $self->ALCHE_SK(),4;
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 4) {
        # NPC dialogue interrupted
        mes "[Pisruik]";
        mes "Alright, did you";
        mes "want to learn more";
        mes "about the medicine that";
        mes "I'm developing? I mean,";
        mes "that's why you came, right?";
        $self->next;
        if ($self->select("No, thanks.:Yes, please.") == 1) {
            mes "[Pisruik]";
            mes "Alright then.";
            mes "Really? Well, I'm";
            mes "willing to spend the";
            mes "time to explain it to";
            mes "you. After all, you did";
            mes "help me out just then.";
            $self->close;
        }
        mes "[Pisruik]";
        mes "I'm working on a new";
        mes "form of medicine that,";
        mes "hopefully, will be used";
        mes "for the betterment and";
        mes "protection of mankind!";
        $self->next;
        mes "[Pisruik]";
        mes "Anyway, this medicine";
        mes "reacts with the human body's";
        mes "digestive enzymes to initiate";
        mes "temporary metabolic changes";
        mes "that artificially stop heat";
        mes "absorption into the body.";
        $self->next;
        mes "[Pisruik]";
        mes "The actual effect of this";
        mes "medicine is that it greatly";
        mes "increases the body's resistance";
        mes "to most forms of heat! However,";
        mes "it will also reduce resistance";
        mes "to cold as a side effect.";
        $self->next;
        mes "[Pisruik]";
        mes "I know my medicine sounds";
        mes "a little weird, but think of";
        mes "the applications! If used in";
        mes "the right situations, this";
        mes "medicine may be quite handy.";
        $self->next;
        mes "[Pisruik]";
        mes "Ah, seeing as you're still";
        mes "here, would you mind helping";
        mes "me again? I need about, hmm,";
        mes "20 Maneater Blossoms. If you";
        mes "could bring them to me, it'd";
        mes "really help me out a lot.";
        $self->next;
        given($self->select("Nope, I'm too busy!:Sure, I'll help you.:What's in it for me?")) {
            when (1) {}
            set $self->ALCHE_SK(),5;
            mes "[Pisruik]";
            mes "I guess I'll have to gather";
            mes "those on my own. Alright, well,";
            mes "seeing as we've both gotten";
            mes "what we wanted, I'll suppose";
            mes "your business with me is done.";
            $self->close;
            when (2) {}
            set $self->ALCHE_SK(),6;
            mes "[Pisruik]";
            mes "Thanks, I really";
            mes "appreciate it. While";
            mes "I'm waiting for you,";
            mes "I can start boiling";
            mes "the Clover extract.";
            $self->next;
            $self->select("Clover extract? What's that for?");
            mes "[Pisruik]";
            mes "Well, I need the Clover";
            mes "extract for a compound";
            mes "that I'm going to make with";
            mes "the Maneater Blossoms. I'm";
            mes "kind of weak, so I try not to";
            mes "travel too far when I can.";
            $self->next;
            mes "[Pisruik]";
            mes "Yeah, ever since I was";
            mes "little, I've had a weak";
            mes "heart and bad eyesight.";
            mes "The doctor tells me to avoid";
            mes "stress and hard work, but";
            mes "researching is my life.";
            if ($self->Sex() == $self->SEX_FEMALE()) {
                $self->next;
                mes "[Pisruik]";
                mes "I wonder...";
                mes "If you understand";
                mes "the way I feel, how";
                mes "much I've had to sacrifice";
                mes "for my dream. Heh, anyway...";
            }
            $self->next;
            mes "[Pisruik]";
            mes "I hope you understand that";
            mes "it's too dangerous for me to";
            mes "gather Maneater Blossoms on";
            mes "my own, so if I'm going to get";
            mes "as much help as I can. Thanks";
            mes "again for being cooperative.";
            $self->close;
            when (3) {}
            mes "[Pisruik]";
            mes "Ha ha ha ha!";
            mes "That's real business";
            mes "like of you! Alright,";
            mes "I may be poor, but if";
            mes "you help me, I'll give you";
            mes "the results of my research.";
            $self->next;
            if ($self->select("Nah, I'm too busy.:Alright, I'll help you.") == 1) {
                set $self->ALCHE_SK(),5;
                mes "[Pisruik]";
                mes "I guess I'll have to gather";
                mes "those on my own. Alright, well,";
                mes "seeing as we've both gotten";
                mes "what we wanted, I'll suppose";
                mes "your business with me is done.";
                $self->close;
            }
            set $self->ALCHE_SK(),6;
            mes "[Pisruik]";
            mes "Thanks, I really";
            mes "appreciate it. While";
            mes "I'm waiting for you,";
            mes "I can start boiling";
            mes "the Clover extract.";
            $self->next;
            $self->select("Clover extract? What's that for?");
            mes "[Pisruik]";
            mes "Well, I need the Clover";
            mes "extract for a compound";
            mes "that I'm going to make with";
            mes "the Maneater Blossoms. I'm";
            mes "kind of weak, so I try not to";
            mes "travel too far when I can.";
            $self->next;
            mes "[Pisruik]";
            mes "Yeah, ever since I was";
            mes "little, I've had a weak";
            mes "heart and bad eyesight.";
            mes "The doctor tells me to avoid";
            mes "stress and hard work, but";
            mes "researching is my life.";
            if ($self->Sex() == $self->SEX_FEMALE()) {
                $self->next;
                mes "[Pisruik]";
                mes "I wonder...";
                mes "If you understand";
                mes "the way I feel, how";
                mes "much I've had to sacrifice";
                mes "for my dream. Heh, anyway...";
            }
            $self->next;
            mes "[Pisruik]";
            mes "I hope you understand that";
            mes "it's too dangerous for me to";
            mes "gather Maneater Blossoms on";
            mes "my own, so if I'm going to get";
            mes "as much help as I can. Thanks";
            mes "again for being cooperative.";
            $self->close;
        }
    }
    elsif ($self->ALCHE_SK() == 5) {
        # refuse bringing Maneater Blossom
        mes "[Pisruik]";
        mes "I'm busy right now.";
        mes "You didn't forget";
        mes "anything did you?";
        mes "If not, you better";
        mes "get going and let";
        mes "me do my work.";
        $self->next;
        if ($self->select("Alright, sorry to bother you.:Can I still help you?") == 1) {
            mes "[Pisruik]";
            mes "Yeah, whatever.";
            mes "Just hurry up and leave";
            mes "so that I can concentrate.";
            $self->close;
        }
        mes "[Pisruik]";
        mes "Huh? What made you";
        mes "change your mind? Well,";
        mes "I can't afford not to accept";
        mes "any help, so I guess that's";
        mes "a \"Yes.\" Yeah, you can help.";
        $self->next;
        mes "[Pisruik]";
        mes "Alright, go and get me";
        mes "20 Maneater Blossoms.";
        mes "If I weren't so sickly, I'd get";
        mes "them myself, but--*Cough* as";
        mes "you can see, I don't feel so well.";
        set $self->ALCHE_SK(),6;
        $self->next;
        mes "[Pisruik]";
        if ($self->Sex() == $self->SEX_FEMALE()) {
            mes "I... I really";
            mes "appreciate your";
            mes "willingness to help";
            mes "me in my research...";
        }
        else {
            mes "I hope you get those";
            mes "items to me as soon as";
            mes "you can. And don't flake";
            mes "out on me this time!";
        }
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 6) {
        if ($self->countitem(1032) > 19) {
            $self->delitem(1032,20);
            set $self->ALCHE_SK(),7;
            mes "[Pisruik]";
            mes "Thanks so much for";
            mes "bringing me these";
            mes "Maneater Blossoms.";
            if ($self->Sex() == $self->SEX_FEMALE()) {
                mes "You don't know how";
                mes "much this means to me~";
            }
            else {
                mes "Now all I have to do";
                mes "is mix these with the";
                mes "Clover extract I prepared.";
            }
            $self->next;
            set $self->ALCHE_SK(),9;
            specialeffect EF_SUI_EXPLOSION;
            mes "[Pisruik]";
            mes "Ah!";
            mes "M-my face!";
            $self->next;
            # ...Pretty Boy mode -_-
            mes "[Pisruik]";
            mes "Hey...";
            mes "Are you alright?";
            mes "That was a pretty";
            mes "big explosion...";
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "Your glasses...";
            mes "They're broken...";
            $self->next;
            if ($self->Sex() == $self->SEX_FEMALE()) {
                mes "^3355FFThe explosion destroyed";
                mes "Pisruik's glasses, revealing";
                mes "the beautiful face of a";
                mes "gorgeous, gorgeous man.^000000";
            }
            else {
                mes "^3355FFThe explosion blew off";
                mes "Pisruik's glasses. Without";
                mes "them, he looks more like";
                mes "a male model than a dorky";
                mes "scientific researcher.^000000";
            }
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "Holy crap!";
            mes "You're one";
            mes "good looking guy!";
            $self->next;
            mes "[Pisruik]";
            mes "I c-can't see too";
            mes "well without my glasses.";
            mes "Well, at least I can tell";
            mes "that you're not bleeding.";
            mes "But are you alright?";
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "Oh, I'm fine.";
            mes "But what are you";
            mes "going to do about";
            mes "your glasses?";
            $self->next;
            mes "[Pisruik]";
            mes "Shoot, you're right.";
            mes "I don't happen to have";
            mes "an extra pair. Hey, can";
            mes "you get me a pair of glasses,";
            mes "the same kind I used to wear?";
            $self->next;
            mes "[Pisruik]";
            mes "I know it's too much";
            mes "to ask you for, but I'm";
            mes "almost blind without them.";
            mes "I can't do very much if I can't";
            mes "even see. I'm really sorry";
            mes "about this, "+ strcharinfo(0) +".";
            $self->close;
        }
        else {
            mes "[Pisruik]";
            mes "Would you come back with";
            mes "20 Maneater Blossoms";
            mes "so that I can finish this";
            mes "medicine I'm working on?";
            mes "Thanks, thanks, I've got";
            mes "to hustle with this project...";
            $self->close;
        }
    }
    elsif ($self->ALCHE_SK() == 7) {
        set $self->ALCHE_SK(),8;
        mes "[Pisruik]";
        mes "Hmmm...";
        mes "Actually, I miscalculated";
        mes "the number of Maneater";
        mes "Blossoms that I need. Would";
        mes "you bring me one more? Sorry, I know it's kind of troublesome...";
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 8) {
        if ($self->countitem(1032) > 0) {
            $self->delitem(1032,1);
            set $self->ALCHE_SK(),7;
            mes "[Pisruik]";
            mes "Thanks so much!";
            mes "Now I finally have the";
            mes "exact amount of Maneater";
            mes "Blossoms that I'll need.";
            if ($self->Sex() == $self->SEX_FEMALE()) {
                mes "I'm really sorry for putting";
                mes "your through all this trouble.";
            }
            else {
                mes "Finally, I begin the most";
                mes "exciting part of this project!";
            }
            $self->next;
            set $self->ALCHE_SK(),9;
            specialeffect EF_SUI_EXPLOSION;
            mes "[Pisruik]";
            mes "Ah!";
            mes "M-my face!";
            $self->next;
            # ...Pretty Boy mode -_-
            mes "[Pisruik]";
            mes "Hey...";
            mes "Are you alright?";
            mes "That was a pretty";
            mes "big explosion...";
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "Your glasses...";
            mes "They're broken...";
            $self->next;
            if ($self->Sex() == $self->SEX_FEMALE()) {
                mes "^3355FFThe explosion destroyed";
                mes "Pisruik's glasses, revealing";
                mes "the beautiful face of a";
                mes "gorgeous, gorgeous man.^000000";
            }
            else {
                mes "^3355FFThe explosion blew off";
                mes "Pisruik's glasses. Without";
                mes "them, he looks more like";
                mes "a male model than a dorky";
                mes "scientific researcher.^000000";
            }
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "Holy crap!";
            mes "You're one";
            mes "good looking guy!";
            $self->next;
            mes "[Pisruik]";
            mes "I c-can't see too";
            mes "well without my glasses.";
            mes "Well, at least I can tell";
            mes "that you're not bleeding.";
            mes "But are you alright?";
            $self->next;
            mes "["+ strcharinfo(0) +"]";
            mes "Oh, I'm fine.";
            mes "But what are you";
            mes "going to do about";
            mes "your glasses?";
            $self->next;
            mes "[Pisruik]";
            mes "Shoot, you're right.";
            mes "I don't happen to have";
            mes "an extra pair. Hey, can";
            mes "you get me a pair of glasses,";
            mes "the same kind I used to wear?";
            $self->next;
            mes "[Pisruik]";
            mes "I know it's too much";
            mes "to ask you for, but I'm";
            mes "almost blind without them.";
            mes "I can't do very much if I can't";
            mes "even see. I'm really sorry";
            mes "about this, "+ strcharinfo(0) +".";
            $self->close;
        }
        else {
            mes "[Pisruik]";
            mes "Hmmm...";
            mes "Actually, I miscalculated";
            mes "the number of Maneater";
            mes "Blossoms that I need. Would";
            mes "you bring me one more? Sorry, I know it's kind of troublesome...";
            $self->close;
        }
    }
    elsif ($self->ALCHE_SK() == 9) {
        mes "^3355FFPisruik is holding his";
        mes "broken glasses, squinting";
        mes "his eyes. It seems he like";
        mes "he really does need them,";
        mes "even if he looks much less";
        mes "dorky without them.^000000";
        $self->next;
        if ($self->select("Let him try a pair of your glasses:Don't give him anything") == 1) {
            if ($self->countitem(2243) > 0) {
                $self->delitem(2243,1);
                set $self->ALCHE_SK(),10;
                # changes the quest steps by deicision.
                mes "["+ strcharinfo(0) +"]";
                mes "Here, why don't you";
                mes "check I'm carrying and";
                mes "see if there's a pair of";
                mes "glasses that you can use?";
                $self->next;
                mes "[Pisruik]";
                mes "Huh? Oh, is that you?";
                mes "Ah, this pair of glasses";
                mes "works! Thanks a lot, now";
                mes "I can see again! Now, let";
                mes "me check the results of the";
                mes "experiment we conducted.";
                $self->next;
                mes "[Pisruik]";
                mes "Okay, the test tube wasn't";
                mes "damaged. Yes, according to";
                mes "these readings, this medicine";
                mes "should be fully functional!";
                mes "I think it was a success!";
                mes "Well, theoretically anyway.";
                $self->next;
                mes "[Pisruik]";
                mes "Hmm, changing the attributes";
                mes "of the human body for certain";
                mes "effects may cause controversy";
                mes "later, but hopefully this thing";
                mes "I've invented will be used for";
                mes "good. Ah, that's right!";
                $self->next;
                mes "[Pisruik]";
                mes "Would you like me to";
                mes "teach you everything I've";
                mes "learned in my research? You";
                mes "should be able to create a new";
                mes "type of potion by making use of";
                mes "the knowledge I can teach you.";
                $self->next;
                if ($self->select("Sure!:No, thanks.") == 1) {
                    mes "[Pisruik]";
                    mes "Great, "+ strcharinfo(0) +"!";
                    mes "I know I can trust you";
                    mes "to use this research for";
                    mes "good and noble ends. Now,";
                    mes "please read this thesis and";
                    mes "all of my additional notes...";
                    $self->next;
                    mes "^3355FFPisruik thoroughly";
                    mes "explains the properties";
                    mes "of his medicine, the reaction";
                    mes "of the human organs to it, as";
                    mes "well as a few warnings about";
                    mes "the medicine's side effects.^000000";
                    $self->next;
                    set $self->ALCHE_SK(),11;
                    $self->getitem(7434),1; # Elemental_Create_Book
                    mes "[Pisruik]";
                    mes "Well, you should be";
                    mes "ready to make your own";
                    mes "potions that are a variation";
                    mes "of my medicine. But you'll";
                    mes "probably need to keep that";
                    mes "thesis as a ready reference.";
                    $self->next;
                    mes "[Pisruik]";
                    if ($self->Sex() == SEX_MALE) {
                        mes "Hopefully, we'll";
                        mes "meet again sometime";
                        mes "in the future. Good luck on";
                        mes "your journeys, adventurer.";
                        mes "*Cough cough* Now... What";
                        mes "will be my next project?";
                    }
                    else {
                        mes "Anyway, I need to be";
                        mes "working on a new project";
                        mes "soon, so I suppose this is";
                        mes "where we part ways for now.";
                        mes "But I must say, it was truly";
                        mes "a great pleasure to meet you...";
                    }
                    $self->close;
                }
                mes "[Pisruik]";
                mes "R-Really...?";
                mes "Well, if you ever change";
                mes "your mind, feel free to come";
                mes "back for me to teach you.";
                if ($self->Sex() == $self->SEX_FEMALE()) {
                    mes "And it's no trouble at all!";
                    mes "I really enjoy your company...";
                }
                $self->close;
            }
            else {
                mes "^3355FFUnfortunately, there";
                mes "is nothing in your inventory";
                mes "that seems like a suitable";
                mes "replacement for Pisruik's";
                mes "broken glasses.^000000";
                $self->close;
            }
        }
        mes "["+ strcharinfo(0) +"]";
        mes "Listen, you look so";
        mes "much better when you're";
        mes "not wearing glasses.";
        $self->next;
        mes "[Pisruik]";
        mes "Excuse me,";
        mes "come again?";
        $self->next;
        mes "["+ strcharinfo(0) +"]";
        mes "Hahahahhaha~!";
        mes "No-nothing at all!";
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 10) {
        mes "[Pisruik]";
        mes "So, "+ strcharinfo(0) +",";
        mes "Would you like me to";
        mes "teach you the results";
        mes "of the research I've''";
        mes "been conducting?";
        $self->next;
        if ($self->select("Yes!:No, thanks.") == 1) {
            mes "[Pisruik]";
            mes "Great, "+ strcharinfo(0) +"!";
            mes "I know I can trust you";
            mes "to use this research for";
            mes "good and noble ends. Now,";
            mes "please read this thesis and";
            mes "all of my additional notes...";
            $self->next;
            mes "^3355FFPisruik thoroughly";
            mes "explains the properties";
            mes "of his medicine, the reaction";
            mes "of the human organs to it, as";
            mes "well as a few warnings about";
            mes "the medicine's side effects.^000000";
            $self->next;
            set $self->ALCHE_SK(),11;
            $self->getitem(7434),1; # Elemental_Create_Book
            mes "[Pisruik]";
            mes "Well, you should be";
            mes "ready to make your own";
            mes "potions that are a variation";
            mes "of my medicine. But you'll";
            mes "probably need to keep that";
            mes "thesis as a ready reference.";
            $self->next;
            mes "[Pisruik]";
            if ($self->Sex() == SEX_MALE) {
                mes "Hopefully, we'll";
                mes "meet again sometime";
                mes "in the future. Good luck on";
                mes "your journeys, adventurer.";
                mes "*Cough cough* Now... What";
                mes "will be my next project?";
            }
            else {
                mes "Anyway, I need to be";
                mes "working on a new project";
                mes "soon, so I suppose this is";
                mes "where we part ways for now.";
                mes "But I must say, it was truly";
                mes "a great pleasure to meet you...";
            }
            $self->close;
        }
        mes "[Pisruik]";
        mes "R-Really...?";
        mes "Well, if you ever change";
        mes "your mind, feel free to come";
        mes "back for me to teach you.";
        if ($self->Sex() == $self->SEX_FEMALE()) {
            mes "And it's no trouble at all!";
            mes "I really enjoy your company...";
        }
        $self->close;
    }
    elsif ($self->ALCHE_SK() == 11) {
        if ($self->countitem(7434) == 0) {
            mes "[Pisruik]";
            mes "Uh oh...";
            mes "You lost the thesis";
            mes "I wrote for you? I don't";
            mes "have the time to write";
            mes "another one for you now...";
            $self->close;
        }
        elsif ($self->countitem(7434) == 1) {
            mes "[Pisruik]";
            mes "So, how have you been";
            mes "using the potions that";
            mes "I've taught you to make?";
            mes "Hopefully, they'll come";
            mes "in handy in your adventures.";
            $self->close;
        }
        elsif ($self->countitem(7434) > 1) {
            mes "[Pisruik]";
            mes "Huh, so copies of my";
            mes "thesis are circulating";
            mes "around in public? Well,";
            mes "I'm sorry, but I don't have";
            mes "time to autograph your copy...";
            $self->close;
        }
    }
    else {
        mes "[Pisruik]";
        mes "Mmm...?";
        mes "Did you need anything";
        mes "in particular? Though,";
        mes "I'm afraid someone in";
        mes "my position won't be";
        mes "much help to you.";
        $self->close;
    }
}
else {
    mes "[Pisruik]";
    mes "Mmm...?";
    mes "Did you need anything";
    mes "in particular? Though,";
    mes "I'm afraid someone in";
    mes "my position won't be";
    mes "much help to you.";
    $self->close;
}{
    {
    }

exit;

{
    my $parse = &parse_rathena_script("", File::Spec->catfile($FindBin::Bin, "master", "alchemist_skills.txt"));
    my $ret;
    my $para;

    while(1)
    {
        print "case?: ";
        my $case = <STDIN>;
        chomp($case);
        my $num = 0;
        my @hits2;

        for my $elm (@$parse)
        {
            my @tmp2 = split(/\[(\d+)\]:/, $elm);

            push(@hits2, [$num, int($tmp2[1])]);

            $num++;
        }

        my @hits3;
        for my $elm (@hits2)
        {
            if ($case == $elm->[1] || $case + 1 == $elm->[1])
            {
                push(@hits3, $parse->[$elm->[0]]);
            }
        }

        my $parse2 = &_parse_rathena_script("", join("\n", @hits3));

        print Dumper $parse2;
    }
}

sub parse_rathena_script
{
    my $self = shift;
    my $path = shift;
    my $file = Mojo::File->new($path);
    my $content = $file->slurp;
    $content =~ s/\r\n|\r|\n/\n/;
    my @tmp;

    if ($content =~ m/(.+?)\{(.+?)\n\}/s)
    {
        my $titie = $1;
        my $body = $2;
        my $ref = &parse_script($body);

        return $ref;
    }
}

sub get_paragraph
{
    my $body = shift;
    $body =~ s/\r\n|\r|\n//g;
    my @list = split //, $body;
    my $count;

    for my $str (@list)
    {
        if ($str =~ /\t/)
        {
            $count++;
        }
        else
        {
            last;
        }
    }

    return $count;
}

sub parse_script
{
    my $body = shift;
    my @tmp = split("{", $body);
    my @ret;

    for my $no (0 .. $#tmp)
    {
        my $line = $tmp[$no];
        my $paragraph = &get_paragraph($line);

        $line =~ s/\r\n|\r|\n/\n/g;
        $line =~ s/$/{/g;

        if ($line =~ /mes/)
        {
            if ($line =~ /if/)
            {
                my @tmp2 = split("\n", $line);
                my $ret;
                my $cnt = 0;

                for my $line2 (@tmp2)
                {
                    my $paragraph2 = &get_paragraph($line2);

                    $line2 =~ s/\r\n|\r|\n/\n/g;
                    $line2 =~ s/^\s+|\s+$//g;
                    $line2 =~ s/^\t+|\t+$//g;

                    if ($line2 =~ /^$/)
                    {
                        next;
                    }

                    push(@{$ret}, "[$paragraph2]:$line2");
                }

                push(@ret, @$ret);
            }
        }
        else
        {
            $line =~ s/^\s+|\s+$//g;
            push(@ret, "[$paragraph]:$line");
        }
    }

    return \@ret;
}

sub _parse_rathena_script
{
    my $self = shift;
    my $content = shift;
    my @contents = split(/\r\n|\r|\n/, $content);
    my $break = qr/(?:next;|close;)/;

    shift(@contents); # prt_church,173,23,4	script	Cleric	79,{
    pop(@contents); # }

    my $skip1 = 1;
    my $para = {};
    my @tmp;
    my $skip2 = 0;
    my $case = "";

    for my $line (@contents)
    {
        my $count = (() = $line =~ m/\t/g);
        $line =~ s/\t//g;

        push(@tmp, $line);

        if ($line =~ /next;|close;|switch|case/)
        {
            if ($line =~ /(case \d+):/)
            {
                if ($case ne $1)
                {
                    $para->{$case} ||= [];
                    push(@{$para->{$case}}, @tmp);
                    @tmp = undef;
                    $case = $1;
                }
            }
        }
    }

    $para->{$case} ||= [];
    push(@{$para->{$case}}, @tmp);

    my $test = {};

    for my $key (keys %$para)
    {
        my $ary = $para->{$key};
        my @tmp1;
        my $cnt1 = 0;

        for my $no (0 .. $#$ary)
        {
            my $line = $ary->[$no] || "";
            if ($line =~ /switch \(select\("(.+?)"\)\)/)
            {
                my $hit = $1;
                my @hits = split(":", $hit);
                unshift(@hits, "---select");
                $test->{$key}->{$cnt1} ||= [];
                push(@{$test->{$key}->{$cnt1}}, @hits);
            }
            push(@tmp1, $line);
            if ($line !~ /^(?:next|close);$/)
            {
                next;
            }
            $test->{$key} ||= {};
            $test->{$key}->{$cnt1} ||= [];
            push(@{$test->{$key}->{$cnt1}}, @tmp1);
            $cnt1++;
            @tmp1 = undef;
        }
    }

    return $test;
}