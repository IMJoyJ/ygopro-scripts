--バスター・マーセナリ
-- 效果：
-- 可以让自己的手卡或者墓地存在的1张「爆裂模式」回到卡组，对方场上存在的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
function c77036039.initial_effect(c)
	-- 在卡片中记录关联卡名「爆裂模式」
	aux.AddCodeList(c,80280737)
	-- 可以让自己的手卡或者墓地存在的1张「爆裂模式」回到卡组，对方场上存在的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77036039,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c77036039.cost)
	e1:SetTarget(c77036039.target)
	e1:SetOperation(c77036039.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡名为「爆裂模式」且能作为代价回到卡组的卡
function c77036039.cfilter(c)
	return c:IsCode(80280737) and c:IsAbleToDeckAsCost()
end
-- 代价处理函数：将手卡或墓地的一张「爆裂模式」回到卡组
function c77036039.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查手卡或墓地是否存在可以回到卡组的「爆裂模式」
	if chk==0 then return Duel.IsExistingMatchingCard(c77036039.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手卡或墓地的一张「爆裂模式」
	local g=Duel.SelectMatchingCard(tp,c77036039.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为代价送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c77036039.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标选择函数：选择对方场上的一张魔法·陷阱卡
function c77036039.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c77036039.filter(chkc) end
	-- 在发动时，检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c77036039.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c77036039.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：破坏选中的魔法·陷阱卡
function c77036039.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
