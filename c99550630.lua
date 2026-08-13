--閃刀術式－アフターバーナー
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。那之后，自己墓地有魔法卡3张以上存在的场合，可以选场上1张魔法·陷阱卡破坏。
function c99550630.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。那之后，自己墓地有魔法卡3张以上存在的场合，可以选场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c99550630.condition)
	e1:SetTarget(c99550630.target)
	e1:SetOperation(c99550630.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定怪兽是否位于主要怪兽区域（序列号小于5，即1~5号主要怪兽区）。
function c99550630.cfilter(c)
	return c:GetSequence()<5
end
-- 效果发动条件：自己的主要怪兽区域没有怪兽存在（额外怪兽区可有怪兽）。
function c99550630.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主要怪兽区域不存在怪兽则返回 true，允许发动。
	return not Duel.IsExistingMatchingCard(c99550630.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的处理：从双方主要怪兽区域选择1只表侧表示怪兽作为对象，并设置破坏该对象的操作信息。
function c99550630.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动的合法性检查：确认场上存在至少1只表侧表示怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方主要怪兽区域选择1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁将执行破坏效果，记录要破坏的对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏对象怪兽；若对象被破坏且自己墓地有3张以上魔法卡，则玩家可选择再破坏场上1张魔法·陷阱卡。
function c99550630.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果相关且被效果破坏成功时，才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取双方场上除本卡以外的所有魔法·陷阱卡，作为后续可选的追加破坏对象集合。
		local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
		-- 判断场上存在可选的魔法·陷阱卡、自己墓地魔法卡数量≥3，并且玩家选择“是”时，才进行追加破坏。
		if dg:GetCount()>0 and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 and Duel.SelectYesNo(tp,aux.Stringid(99550630,0)) then  --"是否选魔法·陷阱卡破坏？"
			-- 中断当前效果处理，使追加破坏作为不同时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 显示选择提示，提示玩家“请选择要破坏的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,1,nil)
			-- 手动显示所选择的魔法·陷阱卡被选为对象的动画。
			Duel.HintSelection(sg)
			-- 将选择的魔法·陷阱卡以效果破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
