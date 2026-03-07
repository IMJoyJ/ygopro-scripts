--風魔の波動
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。选和那只怪兽卡名不同并持有相同属性的场上1只怪兽破坏。
function c2994495.initial_effect(c)
	-- 效果原文内容：①：以场上1只表侧表示怪兽为对象才能发动。选和那只怪兽卡名不同并持有相同属性的场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c2994495.target)
	e1:SetOperation(c2994495.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查目标怪兽是否表侧表示且场上存在满足条件的破坏对象
function c2994495.desfilter1(c,tp)
	-- 效果作用：检查目标怪兽是否表侧表示且场上存在满足条件的破坏对象
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c2994495.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c)
end
-- 效果作用：检查目标怪兽是否表侧表示且属性与指定怪兽相同且卡名不同
function c2994495.desfilter2(c,mc)
	return c:IsFaceup() and c:IsAttribute(mc:GetAttribute()) and not c:IsCode(mc:GetCode())
end
-- 效果作用：处理效果的发动条件和选择目标，包括提示选择表侧表示的怪兽并设置破坏对象
function c2994495.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2994495.desfilter1(chkc,tp) end
	-- 效果作用：检查是否满足发动条件，即场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c2994495.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 效果作用：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择符合条件的表侧表示怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c2994495.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 效果作用：获取与已选怪兽属性相同但卡名不同的怪兽作为可破坏对象
	local g2=Duel.GetMatchingGroup(c2994495.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,g1,g1:GetFirst())
	-- 效果作用：设置连锁操作信息，表明将要破坏指定数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 效果作用：处理效果的发动，包括选择并破坏符合条件的怪兽
function c2994495.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果作用：提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 效果作用：选择符合条件的怪兽作为破坏对象
		local g=Duel.SelectMatchingCard(tp,c2994495.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,tc)
		if g:GetCount()>0 then
			-- 效果作用：显示被选为破坏对象的动画效果
			Duel.HintSelection(g)
			-- 效果作用：以效果原因破坏指定数量的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
