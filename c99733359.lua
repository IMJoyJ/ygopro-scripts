--盾航戦車ステゴサイバー
-- 效果：
-- 「盾航战车 电子剑龙」的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，对方怪兽攻击的场合，那次伤害计算时支付1000基本分才能发动。这张卡从墓地特殊召唤，那次战斗发生的对自己的战斗伤害变成0。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c99733359.initial_effect(c)
	-- 「盾航战车 电子剑龙」的效果1回合只能使用1次。①：这张卡在墓地存在，对方怪兽攻击的场合，那次伤害计算时支付1000基本分才能发动。这张卡从墓地特殊召唤，那次战斗发生的对自己的战斗伤害变成0。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99733359,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,99733359)
	e1:SetCondition(c99733359.condition)
	e1:SetCost(c99733359.cost)
	e1:SetTarget(c99733359.target)
	e1:SetOperation(c99733359.operation)
	c:RegisterEffect(e1)
end
-- c99733359.condition：效果发动条件判定，要求当前回合玩家不是这张卡的控制者（即对方回合），对应对方怪兽攻击的伤害计算时。
function c99733359.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家不是tp，确保在对手回合（对方怪兽攻击）时才能发动。
	return Duel.GetTurnPlayer()~=tp
end
-- c99733359.cost：发动代价处理，需要支付1000基本分。
function c99733359.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：若为chk==0，返回玩家tp能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- c99733359.target：发动时判定，要求自己主要怪兽区有空位且墓地里的这张卡可以特殊召唤，并设置特殊召唤的处理信息。
function c99733359.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空位，用于满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果的处理信息：效果分类为特殊召唤，处理对象为这张卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- c99733359.operation：效果处理时，将这张卡从墓地特殊召唤；成功后为这张卡附加离场时除外的效果，并赋予自己战斗伤害变为0的效果。
function c99733359.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与效果相关并且特殊召唤成功（返回>0）后，才继续执行后续的除外和免伤效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 那次战斗发生的对自己的战斗伤害变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将避免战斗伤害的效果e2注册给当前玩家tp，使tp在本次伤害步骤中受到的战斗伤害变为0。
		Duel.RegisterEffect(e2,tp)
	end
end
