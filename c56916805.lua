--エナジー・ドレイン
-- 效果：
-- 选择自己场上1只以表侧表示存在的怪兽。此怪兽的攻击力·守备力上升对方手卡数量×200点的数值直到结束阶段为止。
function c56916805.initial_effect(c)
	-- 选择自己场上1只以表侧表示存在的怪兽。此怪兽的攻击力·守备力上升对方手卡数量×200点的数值直到结束阶段为止。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：在伤害步骤中，仅能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c56916805.target)
	e1:SetOperation(c56916805.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择处理（选择自己场上1只表侧表示怪兽为对象）
function c56916805.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在效果发动时，检查自己场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽的攻击力·守备力上升对方手卡数量×200点，直到结束阶段为止
function c56916805.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 计算上升的数值：对方手卡数量乘以200
	local val=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*200
	if val~=0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 此怪兽的攻击力上升对方手卡数量×200点的数值直到结束阶段为止。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(val)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
