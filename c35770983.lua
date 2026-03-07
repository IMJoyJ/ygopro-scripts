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
	-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c35770983.regcon)
	e2:SetOperation(c35770983.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。
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
-- 判断是否满足①效果的发动条件，即攻击怪兽为我方恐龙摔跤手怪兽且未为本卡，且攻击怪兽与防守怪兽均处于战斗状态。
function c35770983.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的防守怪兽。
	local d=Duel.GetAttackTarget()
	if not a or not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	return a~=e:GetHandler() and a:IsFaceup() and a:IsSetCard(0x11a) and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle()
end
-- 支付①效果的发动费用，将本卡送去墓地。
function c35770983.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将本卡送去墓地作为①效果的发动费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 处理①效果的发动效果，使攻击怪兽不会被战斗破坏，并设置防守怪兽在伤害步骤结束时攻击力减半。
function c35770983.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的防守怪兽。
	local d=Duel.GetAttackTarget()
	if not a or not d then return end
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 使攻击怪兽在本次战斗中不会被破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
		-- 设置防守怪兽在伤害步骤结束时攻击力减半的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c35770983.atkop2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e2)
	end
end
-- 处理防守怪兽攻击力减半的效果。
function c35770983.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		-- 设置防守怪兽的最终攻击力为原来的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(c:GetBaseAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 判断本卡是否从场上送去墓地，用于触发②效果。
function c35770983.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 为本卡设置一个标记，表示其已从场上送去墓地，用于②效果的发动条件。
function c35770983.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(35770983,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断②效果是否可以发动，即本卡是否已从场上送去墓地。
function c35770983.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(35770983)>0
end
-- 设置②效果的发动目标，判断是否可以将本卡特殊召唤。
function c35770983.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤本卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理②效果的发动效果，将本卡特殊召唤到场上，并设置其离开场上的处理。
function c35770983.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断本卡是否可以特殊召唤，即是否满足特殊召唤条件。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置本卡特殊召唤后，若离开场上则被除外的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
