--レアメタル化・魔法反射装甲
-- 效果：
-- 选择场上表侧表示存在的1只机械族怪兽发动。选择的怪兽的攻击力上升500，那只怪兽为对象的魔法卡的效果只有1次无效。那只怪兽从场上离开时这张卡破坏。
function c12503902.initial_effect(c)
	-- 选择场上表侧表示存在的1只机械族怪兽发动；那只怪兽为对象的魔法卡的效果只有1次无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果发动条件为伤害步骤中伤害计算前才能发动，避免在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c12503902.target)
	e1:SetOperation(c12503902.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c12503902.descon2)
	e3:SetOperation(c12503902.desop2)
	c:RegisterEffect(e3)
end
-- 获取本卡通过SetCardTarget设定的对象怪兽，并检查离场事件涉及的卡组中是否包含该对象，即对象是否从场上离开。
function c12503902.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 作为离场时的诱发处理，将这张卡自身以效果原因破坏。
function c12503902.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡自身破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 筛选条件：表侧表示且机械族的怪兽。
function c12503902.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 目标处理：检查选择对象是否合法；发动时确认存在可选的表侧机械族怪兽；提示并让玩家在自己场上选择1只表侧机械族怪兽作为效果对象。
function c12503902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12503902.filter(chkc) end
	-- 效果发动的合法性检查：若场上不存在任何1只符合条件的表侧机械族怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c12503902.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家弹出选择对象的提示信息（请选择效果的对象），用于引导选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示的机械族怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c12503902.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若本卡仍与效果关联且对象仍是合法的表侧机械族怪兽，则将对象设置为本卡的永续对象，并注册一个持续效果，用于无效以该对象为对象的魔法卡效果。
function c12503902.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的唯一目标怪兽（即先前选择的机械族怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c12503902.filter(tc) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 那只怪兽为对象的魔法卡的效果只有1次无效。
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
-- 判断当前连锁处理的效果是否为魔法卡且带有取对象属性，并检查其对象列表中是否包含本卡的目标怪兽；若包含则满足发动条件。
function c12503902.discon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if not tc or not re:IsActiveType(TYPE_SPELL) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中该魔法卡效果选择的对象卡集合。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g:IsContains(tc)
end
-- 满足条件时，将该魔法卡效果无效，并重置自身效果（此无效效果只能使用一次）。
function c12503902.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁中符合条件的魔法卡效果无效。
	Duel.NegateEffect(ev)
	e:Reset()
end
