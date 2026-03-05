--ライトロード・ハンター ライコウ
-- 效果：
-- ①：这张卡反转的场合发动。可以选场上1张卡破坏。从自己卡组上面把3张卡送去墓地。
function c21502796.initial_effect(c)
	-- 效果原文：①：这张卡反转的场合发动。可以选场上1张卡破坏。从自己卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21502796,0))  --"破坏"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c21502796.target)
	e1:SetOperation(c21502796.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置连锁处理信息，标记将要从卡组送去墓地3张卡
function c21502796.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要从卡组送去墓地3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果作用：检索场上所有卡，询问是否破坏1张，然后从卡组破坏3张
function c21502796.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上所有卡作为可破坏对象
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 判断场上是否有卡且询问玩家是否破坏1张卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21502796,1)) then  --"是否要破坏一张卡？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示选中的卡被选为对象
		Duel.HintSelection(sg)
		-- 将选中的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
	-- 从自己卡组上面把3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
