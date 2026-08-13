--ライトロード・ハンター ライコウ
-- 效果：
-- ①：这张卡反转的场合发动。可以选场上1张卡破坏。从自己卡组上面把3张卡送去墓地。
function c21502796.initial_effect(c)
	-- ①：这张卡反转的场合发动。可以选场上1张卡破坏。从自己卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21502796,0))  --"破坏"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c21502796.target)
	e1:SetOperation(c21502796.operation)
	c:RegisterEffect(e1)
end
-- 该target函数在效果发动前进行合法性检查（chk==0时直接允许发动），并设置后续处理所需的信息：卡组堆墓3张；由于破坏对象在处理时选择，因此不在此处指定对象。
function c21502796.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息，声明此效果包含从卡组送墓地的分类，预计将玩家tp的卡组顶端3张卡送去墓地（对象不确定所以targets为nil，数量为3）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 该operation函数为反转效果的实际处理：先取场上所有卡，若存在卡且玩家选择“是”，则从中选1张破坏；无论是否破坏，都将自己卡组顶端3张送去墓地。
function c21502796.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以tp视角看的双方场上所有卡（包含怪兽区和魔法陷阱区的表侧或里侧卡），作为破坏候选集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 检查场上候选卡数量大于0，并让玩家确认是否发动“破坏1张卡”的追加处理（对应“可以”选1张破坏，不选则不破）。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21502796,1)) then  --"是否要破坏一张卡？"
		-- 弹出选择提示，告知玩家接下来需要选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡显示为对象动画，并记录这些卡被选为对象。
		Duel.HintSelection(sg)
		-- 以效果破坏原因将选中的卡破坏送去墓地（不取对象，处理时选择）。
		Duel.Destroy(sg,REASON_EFFECT)
	end
	-- 以效果原因将玩家tp卡组最上方3张卡送去墓地，完成堆墓。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
