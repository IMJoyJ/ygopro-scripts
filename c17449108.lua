--撲滅の使徒
-- 效果：
-- 盖放的1张魔法或者陷阱卡破坏并且从游戏中除外。陷阱卡的场合把双方卡组确认，和破坏陷阱卡同名卡全部从游戏除外。
function c17449108.initial_effect(c)
	-- 盖放的1张魔法或者陷阱卡破坏并且从游戏中除外。陷阱卡的场合把双方卡组确认，和破坏陷阱卡同名卡全部从游戏除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17449108.target)
	e1:SetOperation(c17449108.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为里侧表示且能够被除外，用于筛选符合破坏并除外条件的魔法陷阱卡。
function c17449108.filter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 发动时的目标选择处理：确认存在可选择的里侧魔法陷阱卡，提示玩家选择1张作为对象，并登记破坏与除外的操作信息。
function c17449108.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c17449108.filter(chkc) end
	-- 在发动条件检查（chk==0）时，判定场上是否存在至少1张满足条件的里侧表示且可除外的魔法陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c17449108.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 向操作者显示选择提示消息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方魔法陷阱区域选择1张里侧表示且可除外的魔法陷阱卡作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c17449108.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置本次连锁的操作信息为破坏效果，登记将破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置本次连锁的操作信息为除外效果，登记将除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：若对象卡仍里侧且与效果相关，将其破坏并除外；若该对象是陷阱卡，则检索双方卡组中所有同名卡并除外，同时确认双方卡组后洗切。
function c17449108.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 以效果原因为由将对象卡破坏，并送去除外区，实现破坏并从游戏中除外。
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
		if tc:IsType(TYPE_TRAP) then
			local code=tc:GetCode()
			-- 从双方卡组中筛选出与被破坏陷阱卡卡名相同的所有卡。
			local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,LOCATION_DECK,nil,code)
			-- 将筛选出的同名卡以表侧表示从游戏中除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			-- 获取对方的卡组（组对象）。
			g=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
			-- 向自己展示对方的卡组，以确认对方卡组内容。
			Duel.ConfirmCards(tp,g)
			-- 获取自己的卡组（组对象）。
			g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
			-- 向对方展示自己的卡组，以确认我方卡组内容。
			Duel.ConfirmCards(1-tp,g)
			-- 洗切我方卡组（因卡组被确认过）。
			Duel.ShuffleDeck(tp)
			-- 洗切对方卡组（因卡组被确认过）。
			Duel.ShuffleDeck(1-tp)
		end
	end
end
