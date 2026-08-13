--ミニチュアライズ
-- 效果：
-- 选择场上表侧表示存在的1只原本攻击力比1000高的怪兽发动。选择怪兽的等级下降1星，攻击力下降1000。那只怪兽不在场上存在时，这张卡破坏。
function c34815282.initial_effect(c)
	-- 选择场上表侧表示存在的1只原本攻击力比1000高的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤以外或伤害计算前，即不能在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c34815282.target)
	e1:SetOperation(c34815282.operation)
	c:RegisterEffect(e1)
	-- 那只怪兽不在场上存在时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c34815282.descon)
	e2:SetOperation(c34815282.desop)
	c:RegisterEffect(e2)
	-- 攻击力下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(-1)
	c:RegisterEffect(e4)
end
-- 过滤条件：选择场上表侧表示存在的原本攻击力比1000高的怪兽，且等级大于0（因为需要下降1星）。
function c34815282.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>1000 and c:GetLevel()>0
end
-- 效果发动时的目标选择处理：选择场上表侧表示存在的1只原本攻击力比1000高的怪兽作为对象。
function c34815282.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34815282.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1只满足条件的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c34815282.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择一张表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际选择1只场上表侧表示且满足条件的怪兽，并将其登记为取对象的目标。
	Duel.SelectTarget(tp,c34815282.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时：若这张卡仍在魔陷区且目标怪兽仍表侧表示并与此效果关联，则将目标怪兽设为这张卡的永续对象，以便持续适用攻守/等级变化和破坏判定。
function c34815282.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 破坏判定条件：这张卡未处于预定破坏状态，且存在永续对象，且该对象在本次离场事件中离场。
function c34815282.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏处理：这张卡因对象怪兽不在场上存在而被破坏。
function c34815282.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以效果原因破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
