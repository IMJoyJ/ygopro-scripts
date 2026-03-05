--宝玉の守護者
-- 效果：
-- ←2 【灵摆】 2→
-- ①：只要这张卡在灵摆区域存在，1回合只有1次，自己场上的「究极宝玉神」怪兽以及「宝玉兽」卡不会被效果破坏。
-- 【怪兽效果】
-- ①：自己的「宝玉兽」怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡解放才能发动。那只进行战斗的自己怪兽攻击力·守备力只在伤害计算时变成原本数值的2倍，伤害步骤结束时破坏。
function c14469229.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，1回合只有1次，自己场上的「究极宝玉神」怪兽以及「宝玉兽」卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCountLimit(1)
	e2:SetTarget(c14469229.indtg)
	e2:SetValue(c14469229.indval)
	c:RegisterEffect(e2)
	-- ①：自己的「宝玉兽」怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡解放才能发动。那只进行战斗的自己怪兽攻击力·守备力只在伤害计算时变成原本数值的2倍，伤害步骤结束时破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14469229,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e3:SetCost(c14469229.cost)
	e3:SetTarget(c14469229.target)
	e3:SetOperation(c14469229.operation)
	c:RegisterEffect(e3)
end
-- 判断目标卡片是否为「宝玉兽」或「究极宝玉神」怪兽
function c14469229.indtg(e,c)
	return c:IsSetCard(0x1034) or (c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x2034))
end
-- 判断破坏原因是否为效果破坏
function c14469229.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检查是否可以解放此卡作为发动代价
function c14469229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置战斗伤害计算时的触发条件和目标
function c14469229.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a=d end
	if chk==0 then return d and a:IsSetCard(0x1034) end
	e:SetLabelObject(a)
end
-- 执行战斗伤害计算时的效果操作
function c14469229.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		local atk=tc:GetBaseAttack()
		local def=tc:GetBaseDefense()
		-- 将目标怪兽的攻击力临时提升为原本的2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def*2)
		tc:RegisterEffect(e2)
		-- 在伤害步骤结束时将此卡破坏
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetOperation(c14469229.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e3)
	end
end
-- 在伤害步骤结束时执行破坏操作
function c14469229.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() then
		-- 将此卡以效果原因破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
