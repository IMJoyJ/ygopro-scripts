--波動共鳴
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的等级直到结束阶段时变成4星。
function c58441120.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的等级直到结束阶段时变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58441120.target)
	e1:SetOperation(c58441120.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示、等级不为4且具有等级的怪兽
function c58441120.filter(c)
	return c:IsFaceup() and not c:IsLevel(4) and c:IsLevelAbove(1)
end
-- 效果发动的靶向处理（检查可行性并选择对象）
function c58441120.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58441120.filter(chkc) end
	-- 在发动阶段，检查场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c58441120.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c58441120.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果解决处理，使目标怪兽的等级直到结束阶段变成4星
function c58441120.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的等级直到结束阶段时变成4星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
