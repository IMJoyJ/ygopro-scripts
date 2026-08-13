--風魔の波動
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。选和那只怪兽卡名不同并持有相同属性的场上1只怪兽破坏。
function c2994495.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。选和那只怪兽卡名不同并持有相同属性的场上1只怪兽破坏。
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
-- 定义对象候选的过滤函数：c为对象候选，要求c表侧表示，且场上存在另一只满足desfilter2条件（与c卡名不同且属性相同）的怪兽。
function c2994495.desfilter1(c,tp)
	-- 判断c是否表侧表示，并检查场上是否存在除c外的满足desfilter2条件的怪兽，以保证有可选对象。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c2994495.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c)
end
-- 定义可破坏怪兽的过滤函数：目标怪兽c须表侧表示，且与对象怪兽mc属性相同、卡名不同。
function c2994495.desfilter2(c,mc)
	return c:IsFaceup() and c:IsAttribute(mc:GetAttribute()) and not c:IsCode(mc:GetCode())
end
-- 发动时的目标处理函数：检查发动合法性，让玩家选择1只表侧表示怪兽作为对象，检索所有可破坏候选怪兽，并登记破坏信息。
function c2994495.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2994495.desfilter1(chkc,tp) end
	-- 发动合法性检查（chk==0时）：场上是否存在满足desfilter1条件的表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c2994495.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 给玩家显示选择提示：请选择表侧表示的怪兽（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上选择1只满足条件的表侧表示怪兽作为效果对象（取对象），并登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c2994495.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 获取场上所有满足desfilter2条件（与所选对象卡名不同且属性相同）的怪兽，作为可被破坏的候选集合（排除对象怪兽自身）。
	local g2=Duel.GetMatchingGroup(c2994495.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,g1,g1:GetFirst())
	-- 登记操作信息：本次效果包含破坏，候选对象为g2，预计破坏1张；供后续连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 效果处理时的操作函数：取出对象怪兽，若其仍表侧表示且与效果关联，则让玩家选择1只符合条件的怪兽并破坏。
function c2994495.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给玩家显示选择提示：请选择要破坏的怪兽（HINTMSG_DESTROY）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从场上选择1只满足desfilter2条件的怪兽作为破坏目标（与对象怪兽卡名不同且属性相同）。
		local g=Duel.SelectMatchingCard(tp,c2994495.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,tc)
		if g:GetCount()>0 then
			-- 显示被选择的破坏对象卡片动画，并标记这些卡被选为对象。
			Duel.HintSelection(g)
			-- 以效果原因将选中的怪兽破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
