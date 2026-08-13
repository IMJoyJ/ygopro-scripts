--罅割れゆく斧
-- 效果：
-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力在每次自己准备阶段下降500。那只怪兽破坏时这张卡破坏。
function c12117532.initial_effect(c)
	-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。
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
	-- 在每次自己准备阶段下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12117532,0))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c12117532.atkcon)
	e3:SetOperation(c12117532.atkop)
	c:RegisterEffect(e3)
	-- 作为对象的怪兽的攻击力在每次自己准备阶段下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(c12117532.atkval)
	c:RegisterEffect(e4)
end
-- 过滤函数：判定怪兽是否表侧表示，用于选择对象。
function c12117532.filter(c)
	return c:IsFaceup()
end
-- 发动时的取对象处理：确认存在表侧表示怪兽，选择场上1只表侧表示怪兽作为对象，并设置操作信息。
function c12117532.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c12117532.filter(chkc) end
	-- 发动合法性检查：确认双方怪兽区域存在至少1只表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c12117532.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作者从双方怪兽区域选择1只表侧表示怪兽作为效果对象，并记录为该连锁的对象。
	local g=Duel.SelectTarget(tp,c12117532.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明此效果涉及使对象卡无效化（配合发动分类），对象为选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理时，若此卡仍与发动效果关联且对象怪兽仍表侧表示且与效果关联，则将此卡设为该怪兽的永续对象，用于持续跟踪攻击力下降与破坏联动。
function c12117532.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 破坏自毁的触发条件：此卡未被预定破坏，且存在永续对象，该对象怪兽因“破坏”原因从场上离场。
function c12117532.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 破坏自毁处理：将这张卡本身以效果破坏。
function c12117532.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏这张卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 攻击力下降效果的发动条件：当前回合是自己回合，且此卡拥有永续对象怪兽。
function c12117532.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前为这张卡的控制者的准备阶段，并且已成功指定对象怪兽。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()~=nil
end
-- 准备阶段时，若存在对象怪兽，给此卡累积1次下降标记，用于后续计算攻击力下降数值。
function c12117532.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc then
		c:RegisterFlagEffect(12117532,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 根据此卡累积的下降标记次数，为对象怪兽提供每次-500的攻击力增减值。
function c12117532.atkval(e,c)
	return e:GetHandler():GetFlagEffect(12117532)*-500
end
