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
	-- ①：1回合1次，对方的主要阶段以及战斗阶段才能把这个效果发动。把1只怪兽上级召唤。
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
-- 效果发动条件：仅当当前为对方回合且处于主要阶段1、主要阶段2或战斗阶段（开始步骤至结束步骤）时，该效果才满足发动条件。
function c18235309.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家，用于判断当前是否为对方回合，以满足“对方的主要阶段以及战斗阶段才能发动”的时点要求。
	local tn=Duel.GetTurnPlayer()
	-- 获取当前所处阶段，用于判断是否处于对方的主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return tn~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end
-- 筛选条件：手牌中的怪兽能够以至少1只怪兽作为解放进行上级召唤（包括表侧攻击表示通常召唤或里侧守备表示覆盖），且不检查通常召唤次数限制。
function c18235309.filter(c)
	return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
end
-- 效果发动时的目标处理：若自己手牌中存在至少1只满足上级召唤条件的怪兽则允许发动，并将本次效果的操作信息标记为“召唤”。
function c18235309.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认自己手牌中是否存在至少1只满足 c18235309.filter 条件的怪兽；若存在则返回 true，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18235309.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置本次效果处理时的操作信息为 CATEGORY_SUMMON，表示效果处理时将进行1只怪兽的上级召唤；因具体召唤哪只怪兽要到处理时选择，所以目标卡设为 nil，数量设为1。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：从手牌中选择1只满足条件的怪兽，再根据玩家选择的表示形式，将其表侧攻击表示上级召唤或里侧守备表示覆盖到场上。
function c18235309.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌中选出1只满足上级召唤条件的怪兽，作为本次效果要召唤的卡片。
	local g=Duel.SelectMatchingCard(tp,c18235309.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		-- 若该怪兽既能表侧攻击表示上级召唤又能里侧守备表示覆盖，则让玩家选择表示形式；若玩家选择表侧攻击表示或该怪兽不能里侧覆盖，则执行表侧上级召唤，否则执行里侧覆盖。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 以不占用每回合通常召唤次数的方式，将选择的怪兽进行表侧攻击表示的上级召唤，至少解放1只怪兽。
			Duel.Summon(tp,tc,true,nil,1)
		else
			-- 以不占用每回合通常召唤次数的方式，将选择的怪兽进行里侧守备表示的上级召唤（覆盖），至少解放1只怪兽。
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
