--EMカレイドスコーピオン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：自己场上的光属性怪兽的攻击力上升300。
-- 【怪兽效果】
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽可以向对方场上的特殊召唤的怪兽全部各作1次攻击。
function c78835747.initial_effect(c)
	-- 启用灵摆怪兽的灵摆属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的光属性怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c78835747.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽可以向对方场上的特殊召唤的怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78835747,0))  --"多次攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c78835747.condition)
	e3:SetTarget(c78835747.target)
	e3:SetOperation(c78835747.operation)
	c:RegisterEffect(e3)
end
-- 过滤出光属性怪兽作为攻击力上升效果的适用对象
function c78835747.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 怪兽效果的发动条件：当前回合玩家可以进入战斗阶段
function c78835747.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 怪兽效果的Target函数：检查并选择自己场上1只表侧表示怪兽作为对象
function c78835747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动效果的准备阶段，检查自己场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 怪兽效果的Operation函数：给对象怪兽赋予向对方场上所有特殊召唤的怪兽各作1次攻击的效果
function c78835747.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽可以向对方场上的特殊召唤的怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(c78835747.atkfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤出特殊召唤的怪兽作为允许攻击的目标
function c78835747.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
