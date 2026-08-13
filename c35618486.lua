--インヴェルズの先鋭
-- 效果：
-- 自己场上存在的这张卡被送去墓地时，选择场上表侧表示存在的1只仪式·融合·同调怪兽破坏。
function c35618486.initial_effect(c)
	-- 自己场上存在的这张卡被送去墓地时，选择场上表侧表示存在的1只仪式·融合·同调怪兽破坏。
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
-- 判定触发条件：这张卡的上一控制者为当前玩家，且之前位于场上（即从自己场上被送去墓地）。
function c35618486.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选可选对象：场上表侧表示且为仪式、融合或同调怪兽。
function c35618486.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO)
end
-- 效果发动时的对象选择处理：确认对象为场上表侧表示的仪式·融合·同调怪兽；发动时选择其中1只作为效果对象，并设置破坏该对象的操作信息。
function c35618486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c35618486.filter(chkc) end
	if chk==0 then return true end
	-- 向当前玩家显示选择破坏对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方主要怪兽区选择1只符合条件的表侧表示仪式·融合·同调怪兽作为效果对象，并登记为本次效果对象。
	local g=Duel.SelectTarget(tp,c35618486.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理时的破坏信息：确定破坏对象为已选择的卡g，数量为g的数量，目标玩家和位置为0（不指定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取回发动时选择的对象，若该卡仍在场上表侧表示且与效果关联，则将其破坏。
function c35618486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
