--D2シールド
-- 效果：
-- 选择自己场上表侧守备表示存在的1只怪兽发动。选择的怪兽的守备力变成原本守备力2倍的数值。
function c71249758.initial_effect(c)
	-- 选择自己场上表侧守备表示存在的1只怪兽发动。选择的怪兽的守备力变成原本守备力2倍的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置发动条件为伤害步骤中伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c71249758.target)
	e1:SetOperation(c71249758.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向处理，用于确认和选择符合条件的对象
function c71249758.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsPosition(POS_FACEUP_DEFENSE) end
	-- 检查自己场上是否存在至少1只表侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_DEFENSE) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧守备表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_DEFENSE)
end
-- 效果处理的执行，使目标怪兽的守备力变成原本守备力的2倍
function c71249758.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local def=tc:GetBaseDefense()
		-- 选择的怪兽的守备力变成原本守备力2倍的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(def*2)
		tc:RegisterEffect(e1)
	end
end
