--罅割れゆく斧
-- 效果：
-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力在每次自己准备阶段下降500。那只怪兽破坏时这张卡破坏。
function c12117532.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力在每次自己准备阶段下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c12117532.target)
	e1:SetOperation(c12117532.operation)
	c:RegisterEffect(e1)
	-- 那只怪兽破坏时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c12117532.descon)
	e2:SetOperation(c12117532.desop)
	c:RegisterEffect(e2)
	-- 攻击下降
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12117532,0))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c12117532.atkcon)
	e3:SetOperation(c12117532.atkop)
	c:RegisterEffect(e3)
	-- 作为对象的怪兽的攻击力在每次自己准备阶段下降500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(c12117532.atkval)
	c:RegisterEffect(e4)
end
-- 筛选场上的表侧表示怪兽
function c12117532.filter(c)
	return c:IsFaceup()
end
-- 选择场上1只表侧表示怪兽作为对象
function c12117532.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c12117532.filter(chkc) end
	-- 检查场上是否存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c12117532.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择1只表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c12117532.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为使对象怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果发动时的操作
function c12117532.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断对象怪兽是否被破坏
function c12117532.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当对象怪兽被破坏时，将此卡破坏
function c12117532.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断是否为自己的准备阶段且对象怪兽存在
function c12117532.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段且对象怪兽存在
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()~=nil
end
-- 准备阶段时执行攻击力下降处理
function c12117532.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc then
		c:RegisterFlagEffect(12117532,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 计算对象怪兽攻击力下降值
function c12117532.atkval(e,c)
	return e:GetHandler():GetFlagEffect(12117532)*-500
end
