--EMオッドアイズ・ユニコーン
-- 效果：
-- ←8 【灵摆】 8→
-- ①：只在这张卡在灵摆区域存在才有1次，自己的「异色眼」怪兽的攻击宣言时，以那只怪兽以外的自己场上1只「娱乐伙伴」怪兽为对象才能发动。那只攻击怪兽的攻击力直到战斗阶段结束时上升作为对象的怪兽的原本攻击力数值。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功时，以自己墓地1只「娱乐伙伴」怪兽为对象才能发动。自己回复那只怪兽的攻击力数值的基本分。
function c86157908.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，自己的「异色眼」怪兽的攻击宣言时，以那只怪兽以外的自己场上1只「娱乐伙伴」怪兽为对象才能发动。那只攻击怪兽的攻击力直到战斗阶段结束时上升作为对象的怪兽的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c86157908.atkcon)
	e2:SetTarget(c86157908.atktg)
	e2:SetOperation(c86157908.atkop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功时，以自己墓地1只「娱乐伙伴」怪兽为对象才能发动。自己回复那只怪兽的攻击力数值的基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c86157908.target)
	e3:SetOperation(c86157908.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示且字段为「娱乐伙伴」的怪兽
function c86157908.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 灵摆效果发动条件：自己场上的「异色眼」怪兽进行攻击宣言时
function c86157908.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(tp) and at:IsSetCard(0x99)
end
-- 灵摆效果的目标选择：以攻击怪兽以外的自己场上1只表侧表示的「娱乐伙伴」怪兽为对象
function c86157908.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86157908.atkfilter(chkc) and chkc~=at end
	-- 检查自己场上是否存在除攻击怪兽以外的、表侧表示的「娱乐伙伴」怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c86157908.atkfilter,tp,LOCATION_MZONE,0,1,at) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只除攻击怪兽以外的表侧表示「娱乐伙伴」怪兽作为效果对象
	Duel.SelectTarget(tp,c86157908.atkfilter,tp,LOCATION_MZONE,0,1,1,at)
end
-- 灵摆效果的处理：使攻击怪兽的攻击力直到战斗阶段结束时上升作为对象的怪兽的原本攻击力数值
function c86157908.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「娱乐伙伴」怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取当前进行攻击的怪兽
	local at=Duel.GetAttacker()
	if at:IsFaceup() and at:IsRelateToBattle() and at:IsAttackable() and not at:IsStatus(STATUS_ATTACK_CANCELED)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		-- 那只攻击怪兽的攻击力直到战斗阶段结束时上升作为对象的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		at:RegisterEffect(e1)
	end
end
-- 过滤条件：自己墓地中攻击力大于0的「娱乐伙伴」怪兽
function c86157908.filter(c)
	return c:IsSetCard(0x9f) and c:GetAttack()>0
end
-- 怪兽效果的目标选择：以自己墓地1只「娱乐伙伴」怪兽为对象，并设置回复基本分的操作信息
function c86157908.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86157908.filter(chkc) end
	-- 检查自己墓地是否存在满足条件的「娱乐伙伴」怪兽
	if chk==0 then return Duel.IsExistingTarget(c86157908.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只「娱乐伙伴」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86157908.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	-- 设置回复基本分的操作信息，数值为目标怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
-- 怪兽效果的处理：自己回复作为对象的怪兽的攻击力数值的基本分
function c86157908.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地中的「娱乐伙伴」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 玩家回复目标怪兽攻击力数值的基本分
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
