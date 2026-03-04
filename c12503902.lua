--レアメタル化・魔法反射装甲
-- 效果：
-- 选择场上表侧表示存在的1只机械族怪兽发动。选择的怪兽的攻击力上升500，那只怪兽为对象的魔法卡的效果只有1次无效。那只怪兽从场上离开时这张卡破坏。
function c12503902.initial_effect(c)
	-- 选择场上表侧表示存在的1只机械族怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果不能在伤害计算后进行。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c12503902.target)
	e1:SetOperation(c12503902.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c12503902.descon2)
	e3:SetOperation(c12503902.desop2)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否离开场上的条件函数。
function c12503902.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 执行破坏效果的函数。
function c12503902.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡因效果破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断目标是否为表侧表示的机械族怪兽的过滤函数。
function c12503902.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 选择效果对象的函数。
function c12503902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12503902.filter(chkc) end
	-- 检查是否有满足条件的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c12503902.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择一个满足条件的怪兽作为对象。
	Duel.SelectTarget(tp,c12503902.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数。
function c12503902.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c12503902.filter(tc) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 为对象怪兽设置魔法卡无效效果的处理。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(c12503902.discon2)
		e1:SetOperation(c12503902.disop2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 判断是否为针对该怪兽的魔法卡效果。
function c12503902.discon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if not tc or not re:IsActiveType(TYPE_SPELL) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g:IsContains(tc)
end
-- 执行魔法卡效果无效的函数。
function c12503902.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效。
	Duel.NegateEffect(ev)
	e:Reset()
end
