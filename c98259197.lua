--おジャマッスル
-- 效果：
-- 选择场上1只表侧表示存在的「扰乱王」。选择的「扰乱王」以外的名字中带有「扰乱」的怪兽全破坏。每破坏1只怪兽，选择的1只「扰乱王」的攻击力上升1000。
function c98259197.initial_effect(c)
	-- 选择场上1只表侧表示存在的「扰乱王」。选择的「扰乱王」以外的名字中带有「扰乱」的怪兽全破坏。每破坏1只怪兽，选择的1只「扰乱王」的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c98259197.target)
	e1:SetOperation(c98259197.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「扰乱王」，且场上存在至少1只该卡以外的「扰乱」怪兽
function c98259197.filter(c)
	return c:IsFaceup() and c:IsCode(90140980)
		-- 检查场上是否存在至少1只该「扰乱王」以外的「扰乱」怪兽
		and Duel.IsExistingMatchingCard(c98259197.filter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 过滤条件：场上表侧表示的名字中带有「扰乱」的怪兽
function c98259197.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xf)
end
-- 效果发动的准备阶段：验证并选择1只「扰乱王」作为对象，并注册破坏操作的信息
function c98259197.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c98259197.filter(chkc) end
	-- 在发动阶段，检查场上是否存在符合条件的「扰乱王」
	if chk==0 then return Duel.IsExistingTarget(c98259197.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「扰乱王」作为效果对象
	local g=Duel.SelectTarget(tp,c98259197.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 获取场上除选择的「扰乱王」以外的所有「扰乱」怪兽
	local dg=Duel.GetMatchingGroup(c98259197.filter2,0,LOCATION_MZONE,LOCATION_MZONE,g:GetFirst())
	-- 设置效果处理信息：准备破坏上述获取到的「扰乱」怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理：破坏选择的「扰乱王」以外的「扰乱」怪兽，并根据破坏数量提升该「扰乱王」的攻击力
function c98259197.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「扰乱王」
	local tc=Duel.GetFirstTarget()
	-- 获取场上除该「扰乱王」以外的所有「扰乱」怪兽
	local dg=Duel.GetMatchingGroup(c98259197.filter2,0,LOCATION_MZONE,LOCATION_MZONE,tc)
	-- 破坏这些「扰乱」怪兽，并获取实际被破坏的怪兽数量
	local ct=Duel.Destroy(dg,REASON_EFFECT)
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 每破坏1只怪兽，选择的1只「扰乱王」的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
