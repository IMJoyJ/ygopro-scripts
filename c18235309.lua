--連撃の帝王
-- 效果：
-- ①：1回合1次，对方的主要阶段以及战斗阶段才能把这个效果发动。把1只怪兽上级召唤。
function c18235309.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：1回合1次，对方的主要阶段以及战斗阶段才能把这个效果发动。把1只怪兽上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18235309,0))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c18235309.condition)
	e3:SetTarget(c18235309.target)
	e3:SetOperation(c18235309.activate)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断是否满足发动条件，即当前回合玩家不是自己，且当前阶段为对方的主要阶段1、主要阶段2或战斗阶段。
function c18235309.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前回合玩家的玩家编号。
	local tn=Duel.GetTurnPlayer()
	-- 规则层面作用：获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return tn~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end
-- 规则层面作用：定义过滤函数，用于筛选可以通常召唤或盖放的怪兽。
function c18235309.filter(c)
	return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
end
-- 规则层面作用：设置效果的目标，检查手牌中是否存在满足条件的怪兽。
function c18235309.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查手牌中是否存在至少一张可以通常召唤或盖放的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18235309.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：设置连锁操作信息，表示将要处理一个上级召唤的效果。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 规则层面作用：处理效果发动时的执行逻辑，包括提示选择、选取目标怪兽并进行通常召唤或盖放。
function c18235309.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：向玩家发送提示信息，提示其选择要召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 规则层面作用：从手牌中选择一张满足条件的怪兽作为目标。
	local g=Duel.SelectMatchingCard(tp,c18235309.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 规则层面作用：判断是否选择攻击表示进行通常召唤，若可通常召唤且可盖放，则由玩家选择表示形式。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 规则层面作用：执行通常召唤操作，将目标怪兽通常召唤。
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 规则层面作用：执行盖放操作，将目标怪兽以守备表示盖放。
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
