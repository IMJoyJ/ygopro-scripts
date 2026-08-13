--フリッグのリンゴ
-- 效果：
-- ①：自己场上没有怪兽存在，自己受到战斗伤害时才能发动。自己基本分回复受到的伤害的数值，在自己场上把1只「邪精衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成和这个效果让自己回复的数值相同。
function c42671151.initial_effect(c)
	-- ①：自己场上没有怪兽存在，自己受到战斗伤害时才能发动。自己基本分回复受到的伤害的数值，在自己场上把1只「邪精衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成和这个效果让自己回复的数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c42671151.condition)
	e1:SetTarget(c42671151.target)
	e1:SetOperation(c42671151.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，用于判断是否满足“自己场上没有怪兽存在，自己受到战斗伤害”这一发动条件。
function c42671151.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动条件的具体判定：受到战斗伤害的玩家是自己（ep==tp），并且自己场上没有怪兽（主要怪兽区数量为0）。
	return ep==tp and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义效果发动时的目标确认函数，在发动时检查空位和特殊召唤可行性，并设置效果处理时要执行的操作信息。
function c42671151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区域，用于后续特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己是否可以特殊召唤「邪精衍生物」（恶魔族·暗·1星，攻/守用-2表示数值视为？）；只有满足这两个条件，效果才可以发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,42671152,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：本效果包含回复LP，目标玩家为自己，预定回复的数值为受到的战斗伤害值ev。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
	-- 设置操作信息：本效果将特殊召唤1只衍生物（token），因此标记CATEGORY_TOKEN。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果将进行特殊召唤，预定特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义效果处理时的操作：先回复自己的LP，若回复了完整数值且场上仍有空位且能特招衍生物，则生成「邪精衍生物」并使其攻守变为回复值，否则不处理。
function c42671151.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，自己回复相当于受到的战斗伤害数值的LP（由于是效果回复），并记录实际回复值到变量rec。
	local rec=Duel.Recover(tp,ev,REASON_EFFECT)
	-- 若实际回复值不等于原本战斗伤害数值（如受到回复化为伤害的效果影响），或自己场上已没有可用的主要怪兽区，则后续特殊召唤不再进行。
	if rec~=ev or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或者自己当前不能特殊召唤「邪精衍生物」，则整个效果处理结束，不进行特殊召唤。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,42671152,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建1只卡号为42671152的「邪精衍生物」衍生物，持有者为自己。
	local token=Duel.CreateToken(tp,42671152)
	-- 以特殊召唤步骤的方式，将该衍生物以表侧表示特殊召唤到自己场上；之后可继续在其上附加攻守变化效果。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 这衍生物的攻击力·守备力变成和这个效果让自己回复的数值相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，宣告本次特殊召唤成功，并触发特殊召唤成功时的相关时点。
	Duel.SpecialSummonComplete()
end
