--白い忍者
-- 效果：
-- 反转：破坏场上1只守备表示的怪兽。
function c1571945.initial_effect(c)
	-- 反转：破坏场上1只守备表示的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1571945,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c1571945.target)
	e1:SetOperation(c1571945.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定怪兽是否为守备表示，用于选择对象时筛选符合条件的怪兽。
function c1571945.filter(c)
	return c:IsDefensePos()
end
-- 效果发动时的取对象处理：选择场上1只守备表示的怪兽作为对象，并设置破坏该对象的操作信息。
function c1571945.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1571945.filter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上的怪兽区域选择1只守备表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c1571945.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的破坏操作信息（对象为g，数量为g的数量），用于效果发动后的连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：取得对象怪兽，若该怪兽仍为守备表示且与效果存在关联，则将其破坏。
function c1571945.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 以“效果”为破坏原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
