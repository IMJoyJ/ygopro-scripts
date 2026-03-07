--インヴェルズの先鋭
-- 效果：
-- 自己场上存在的这张卡被送去墓地时，选择场上表侧表示存在的1只仪式·融合·同调怪兽破坏。
function c35618486.initial_effect(c)
	-- 效果原文：自己场上存在的这张卡被送去墓地时，选择场上表侧表示存在的1只仪式·融合·同调怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35618486,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c35618486.condition)
	e1:SetTarget(c35618486.target)
	e1:SetOperation(c35618486.operation)
	c:RegisterEffect(e1)
end
-- 规则层面：检查这张卡是否从前场离开，且离开时的控制者是自己。
function c35618486.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面：筛选场上表侧表示存在的仪式·融合·同调怪兽。
function c35618486.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO)
end
-- 规则层面：选择目标怪兽并设置操作信息。
function c35618486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c35618486.filter(chkc) end
	if chk==0 then return true end
	-- 规则层面：提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面：从场上选择1只符合条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c35618486.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面：设置连锁操作信息，表明将要破坏目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面：执行破坏效果，将目标怪兽破坏。
function c35618486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁处理的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面：以效果为原因将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
