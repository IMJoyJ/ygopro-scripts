--閃刀術式－ジャミングウェーブ
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上盖放的1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，自己墓地有魔法卡3张以上存在的场合，可以选场上1只怪兽破坏。
function c25955749.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上盖放的1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，自己墓地有魔法卡3张以上存在的场合，可以选场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c25955749.condition)
	e1:SetTarget(c25955749.target)
	e1:SetOperation(c25955749.activate)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否位于主要怪兽区域（区域编号0-4，排除额外怪兽区）。
function c25955749.cfilter(c)
	return c:GetSequence()<5
end
-- 效果发动条件：自己的主要怪兽区域没有怪兽存在。
function c25955749.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定己方场上主要怪兽区域不存在任何怪兽（用cfilter过滤主要怪兽区的卡，数量为0）。
	return not Duel.IsExistingMatchingCard(c25955749.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 对象选择条件：里侧表示的魔法·陷阱卡（即场上盖放的魔陷）。
function c25955749.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标处理：选择场上1张盖放的魔法·陷阱卡作为对象（不能选择本卡），并设置破坏相关信息。
function c25955749.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c25955749.filter(chkc) and chkc~=e:GetHandler() end
	-- 在确认发动时检查是否存在满足条件的对象（场上除本卡以外有里侧表示的魔陷）。
	if chk==0 then return Duel.IsExistingTarget(c25955749.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 弹出选择提示文字“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1张里侧表示的魔法·陷阱卡作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c25955749.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：破坏1张卡（目标为已选对象）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：先将对象卡破坏；若自己墓地有3张以上魔法卡且场上有怪兽，则询问是否追加破坏1只怪兽。
function c25955749.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与该效果关联且成功被效果破坏；若成立则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 获取双方场上所有怪兽（包含额外怪兽区）作为追加破坏的候选集合。
		local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 满足追加破坏条件：场上存在怪兽，自己墓地有3张以上魔法卡，且玩家选择“是”。
		if dg:GetCount()>0 and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 and Duel.SelectYesNo(tp,aux.Stringid(25955749,0)) then  --"是否选怪兽卡破坏？"
			-- 中断当前效果连锁，使后续的追加破坏处理被视为独立处理，避免同连锁同时破坏。
			Duel.BreakEffect()
			-- 弹出选择提示文字“请选择要破坏的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,1,nil)
			-- 手动显示选中的怪兽被选为对象的动画，并记录该卡成为对象。
			Duel.HintSelection(sg)
			-- 将选中的怪兽以效果原因破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
