--ミニチュアライズ
-- 效果：
-- 选择场上表侧表示存在的1只原本攻击力比1000高的怪兽发动。选择怪兽的等级下降1星，攻击力下降1000。那只怪兽不在场上存在时，这张卡破坏。
function c34815282.initial_effect(c)
	-- 创建一张永续效果，用于发动此卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制此效果只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c34815282.target)
	e1:SetOperation(c34815282.operation)
	c:RegisterEffect(e1)
	-- 创建一个当目标怪兽离场时触发的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c34815282.descon)
	e2:SetOperation(c34815282.desop)
	c:RegisterEffect(e2)
	-- 创建一个使目标怪兽攻击力下降1000的效果
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
-- 筛选场上表侧表示且原本攻击力大于1000的怪兽
function c34815282.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>1000 and c:GetLevel()>0
end
-- 选择场上表侧表示存在的1只原本攻击力比1000高的怪兽作为目标
function c34815282.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34815282.filter(chkc) end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c34815282.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c34815282.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 设置效果处理时将目标怪兽设为当前效果的对象
function c34815282.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断目标怪兽是否在场上存在
function c34815282.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当效果适用时，将此卡破坏
function c34815282.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡以效果原因破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
