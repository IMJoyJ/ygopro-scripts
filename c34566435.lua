--エッジインプ・DTモドキ
-- 效果：
-- 这张卡在规则上也当作「魔玩具」卡使用。「锋利小鬼·仿DT」的效果1回合只能使用1次。
-- ①：以自己的场上·墓地1只「魔玩具」融合怪兽为对象才能发动。这张卡的攻击力·守备力直到回合结束时变成和那只怪兽的原本数值相同。
function c34566435.initial_effect(c)
	-- 效果原文内容：①：以自己的场上·墓地1只「魔玩具」融合怪兽为对象才能发动。这张卡的攻击力·守备力直到回合结束时变成和那只怪兽的原本数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34566435,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,34566435)
	e1:SetTarget(c34566435.target)
	e1:SetOperation(c34566435.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「魔玩具」融合怪兽（在场上或墓地）
function c34566435.filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
end
-- 效果作用：选择对象怪兽
function c34566435.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c34566435.filter(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c34566435.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c34566435.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end
-- 效果作用：将自身攻守变为与对象怪兽的原本数值相同
function c34566435.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup()) then
		-- 将自身攻击力变为对象怪兽的原本攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense())
		c:RegisterEffect(e2)
	end
end
