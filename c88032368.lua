--セカンド・ブースター
-- 效果：
-- 把这张卡解放，选择自己场上表侧攻击表示存在的1只怪兽发动。选择的怪兽的攻击力直到结束阶段时上升1500。
function c88032368.initial_effect(c)
	-- 把这张卡解放，选择自己场上表侧攻击表示存在的1只怪兽发动。选择的怪兽的攻击力直到结束阶段时上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88032368,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c88032368.cost)
	e1:SetTarget(c88032368.target)
	e1:SetOperation(c88032368.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：检查自身是否可以解放，并执行解放操作
function c88032368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果目标：检查并选择自己场上1只表侧攻击表示的怪兽作为效果对象
function c88032368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsPosition(POS_FACEUP_ATTACK) end
	-- 在发动效果前，检查自己场上是否存在除自身以外的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,e:GetHandler(),POS_FACEUP_ATTACK) end
	-- 设置提示信息为：请选择表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择自己场上1只表侧攻击表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK)
end
-- 效果处理：使选择的对象怪兽攻击力直到结束阶段上升1500
function c88032368.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 选择的怪兽的攻击力直到结束阶段时上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
