--EMパートナーガ
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以自己场上1只怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」卡数量×300。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合，以自己场上1只怪兽为对象才能发动。那只怪兽的攻击力上升自己场上的「娱乐伙伴」怪兽数量×300。
-- ②：只要这张卡在怪兽区域存在，5星以下的怪兽不能攻击。
function c69211541.initial_effect(c)
	-- 添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69211541,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c69211541.atktg)
	e2:SetOperation(c69211541.atkop1)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己场上1只怪兽为对象才能发动。那只怪兽的攻击力上升自己场上的「娱乐伙伴」怪兽数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69211541,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(c69211541.atktg)
	e3:SetOperation(c69211541.atkop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：只要这张卡在怪兽区域存在，5星以下的怪兽不能攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤等级5以下的怪兽作为不能攻击的对象
	e5:SetTarget(aux.TargetBoolFunction(Card.IsLevelBelow,5))
	c:RegisterEffect(e5)
end
-- 效果发动时的对象选择处理
function c69211541.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为对象的可选表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤自己场上表侧表示的「娱乐伙伴」卡
function c69211541.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 灵摆效果①的实际效果处理
function c69211541.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 计算自己场上表侧表示的「娱乐伙伴」卡数量
	local ct=Duel.GetMatchingGroupCount(c69211541.filter,tp,LOCATION_ONFIELD,0,nil)
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」卡数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果①的实际效果处理
function c69211541.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 计算自己场上表侧表示的「娱乐伙伴」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c69211541.filter,tp,LOCATION_MZONE,0,nil)
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升自己场上的「娱乐伙伴」怪兽数量×300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
