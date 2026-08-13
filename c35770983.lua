--ダイナレスラー・マーシャルアンキロ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡以外的自己的「恐龙摔跤手」怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那只对方怪兽的攻击力在伤害步骤结束时变成一半。
-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c35770983.initial_effect(c)
	-- ①：这张卡以外的自己的「恐龙摔跤手」怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那只对方怪兽的攻击力在伤害步骤结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35770983,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(c35770983.atkcon)
	e1:SetCost(c35770983.atkcost)
	e1:SetOperation(c35770983.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c35770983.regcon)
	e2:SetOperation(c35770983.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35770983,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,35770983)
	e3:SetCondition(c35770983.spcon)
	e3:SetTarget(c35770983.sptg)
	e3:SetOperation(c35770983.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：在伤害计算时，判定是否为这张卡以外的自己的「恐龙摔跤手」怪兽与对方怪兽进行战斗，且双方怪兽均表侧表示并仍与战斗相关。
function c35770983.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽，用于判定战斗双方。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽，用于判定战斗双方。
	local d=Duel.GetAttackTarget()
	if not a or not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	return a~=e:GetHandler() and a:IsFaceup() and a:IsSetCard(0x11a) and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle()
end
-- ①效果的发动代价：检查能否把手卡·场上的这张卡送去墓地，若能则将其作为代价送入墓地。
function c35770983.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以代价（REASON_COST）将这张卡送去墓地，支付①效果的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果的处理：使那只自己怪兽在这次战斗中不会被战斗破坏，并让对方怪兽在伤害步骤结束时攻击力变为原攻击力的一半。
function c35770983.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽；若攻击者是对方怪兽，则后续将其与攻击目标交换，以正确区分己方怪兽与对方怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽，用于确定要保护的己方怪兽和要降低攻击力的对方怪兽。
	local d=Duel.GetAttackTarget()
	if not a or not d then return end
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
		-- 那只对方怪兽的攻击力在伤害步骤结束时变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c35770983.atkop2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e2)
	end
end
-- 伤害步骤结束时：若对方怪兽仍与这次战斗相关，则将其攻击力变成原本攻击力的一半（向上取整）。
function c35770983.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力在伤害步骤结束时变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(c:GetBaseAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 辅助效果的触发条件：这张卡是从场上送去墓地（原位置为场上），用于记录②效果的发动时机。
function c35770983.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 为这张卡标记一个flag（35770983），表示本回合从场上送去墓地过；该flag在结束阶段重置。
function c35770983.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(35770983,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ②效果的发动条件：这张卡拥有本回合从场上送去墓地过的flag，才可在结束阶段发动。
function c35770983.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(35770983)>0
end
-- ②效果的发动目标检查：确认自己场上有可用的主要怪兽区，且这张卡可以被特殊召唤。
function c35770983.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次效果将特殊召唤这张卡，并指定特殊召唤类别供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将这张卡从墓地特殊召唤；若特殊召唤成功，为其附加‘从场上离开的场合除外’的效果。
function c35770983.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联，且特殊召唤成功（返回值不为0）时，继续附加除外的永续效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
