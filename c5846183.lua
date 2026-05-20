--遮断機塊ブレイカーバンクル
-- 效果：
-- ①：自己的「机块」怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡丢弃才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
-- ②：自己场上的「机块」怪兽被效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
function c5846183.initial_effect(c)
	-- ①：自己的「机块」怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡丢弃才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5846183,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5846183.atkcon)
	e1:SetCost(c5846183.atkcost)
	e1:SetOperation(c5846183.atkop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「机块」怪兽被效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetTarget(c5846183.reptg)
	e2:SetValue(c5846183.repval)
	e2:SetOperation(c5846183.repop)
	c:RegisterEffect(e2)
end
-- 判断是否在自己的「机块」怪兽与对方怪兽进行战斗的伤害计算时
function c5846183.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标怪兽设为被攻击的己方怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	e:SetLabelObject(tc)
	local bc=tc:GetBattleTarget()
	return bc and tc:IsSetCard(0x14b)
end
-- 丢弃手牌中的这张卡作为发动的代价
function c5846183.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡作为代价丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 执行伤害计算时手牌效果的操作（使怪兽不会被战斗破坏，且战斗伤害变成0）
function c5846183.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 那只自己怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 那次战斗发生的对自己的战斗伤害变成0。②：自己场上的「机块」怪兽被效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 向玩家注册战斗伤害变成0的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤自己场上因效果破坏的表侧表示「机块」怪兽
function c5846183.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x14b)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件（这张卡可以除外，且有符合条件的「机块」怪兽被效果破坏）
function c5846183.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c5846183.repfilter,1,nil,tp)
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 过滤并确定需要代替破坏的「机块」怪兽
function c5846183.repval(e,c)
	return c5846183.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果，将这张卡除外
function c5846183.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
