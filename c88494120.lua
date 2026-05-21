--不屈の闘志
-- 效果：
-- ①：自己场上的表侧表示怪兽只有1只的场合，以那1只怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升对方场上的攻击力最低的怪兽的攻击力数值。
function c88494120.initial_effect(c)
	-- ①：自己场上的表侧表示怪兽只有1只的场合，以那1只怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升对方场上的攻击力最低的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c88494120.condition)
	e1:SetTarget(c88494120.target)
	e1:SetOperation(c88494120.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：不在伤害计算后，且自己场上表侧表示怪兽只有1只
function c88494120.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前时点是否在伤害步骤的伤害计算前
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 判定自己场上的表侧表示怪兽数量是否等于1
		and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1
end
-- 判定效果发动目标并选择对象
function c88494120.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return false end
		local mg,atk=g:GetMinGroup(Card.GetAttack)
		-- 判定对方场上最低攻击力是否大于0，且自己场上存在可作为对象的表侧表示怪兽
		return atk>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽攻击力上升对方场上攻击力最低怪兽的攻击力数值，直到回合结束
function c88494120.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		local mg,atk=g:GetMinGroup(Card.GetAttack)
		-- 那只怪兽的攻击力直到回合结束时上升对方场上的攻击力最低的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
