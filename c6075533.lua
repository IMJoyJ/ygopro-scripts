--トリシューラの鼓動
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的「冰结界」同调怪兽种类的以下效果适用。
-- ●1种类以上：对方场上1张卡除外。
-- ●2种类以上：对方墓地1张卡除外。
-- ●3种类以上：对方手卡随机1张除外。
-- ②：自己场上的「冰结界」同调怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把墓地的这张卡除外才能发动。那个效果无效。
function c6075533.initial_effect(c)
	-- ①：自己场上的「冰结界」同调怪兽种类的以下效果适用。●1种类以上：对方场上1张卡除外。●2种类以上：对方墓地1张卡除外。●3种类以上：对方手卡随机1张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6075533)
	e1:SetTarget(c6075533.target)
	e1:SetOperation(c6075533.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「冰结界」同调怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把墓地的这张卡除外才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,6075534)
	e2:SetCondition(c6075533.discon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c6075533.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「冰结界」同调怪兽
function c6075533.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f) and c:IsType(TYPE_SYNCHRO)
end
-- ①号效果的发动准备与可行性检测
function c6075533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有的「冰结界」同调怪兽
	local g=Duel.GetMatchingGroup(c6075533.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 检测是否满足1种类以上且对方场上有可除外的卡
	if chk==0 then return ct>=1 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检测是否满足2种类以上且对方墓地有可除外的卡
		or ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		-- 检测是否满足3种类以上且对方手牌有可除外的卡
		or ct>=3 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	local rct=0
	local loc=0
	-- 若满足1种类以上且对方场上有可除外的卡，则累加除外数量和区域
	if ct>=1 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) then
		rct=rct+1
		loc=loc+LOCATION_ONFIELD
	end
	-- 若满足2种类以上且对方墓地有可除外的卡，则累加除外数量和区域
	if ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) then
		rct=rct+1
		loc=loc+LOCATION_GRAVE
	end
	-- 若满足3种类以上且对方手牌有可除外的卡，则累加除外数量和区域
	if ct>=3 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) then
		rct=rct+1
		loc=loc+LOCATION_HAND
	end
	-- 设置除外操作的信息，包括预计除外的卡片数量和区域
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,rct,0,loc)
end
-- ①号效果的处理函数
function c6075533.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的「冰结界」同调怪兽
	local g=Duel.GetMatchingGroup(c6075533.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local rflag=false
	if ct>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择对方场上1张可除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 手动为选中的卡片显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的对方场上的卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			rflag=true
		end
	end
	if ct>1 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择对方墓地1张可除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		if g:GetCount()>0 then
			-- 如果之前已经执行过除外操作，则中断效果，使后续处理不视为同时处理
			if rflag then Duel.BreakEffect() end
			-- 将选中的对方墓地的卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			rflag=true
		end
	end
	if ct>2 then
		-- 获取对方手牌中可除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if g:GetCount()>0 then
			-- 如果之前已经执行过除外操作，则中断效果，使后续处理不视为同时处理
			if rflag then Duel.BreakEffect() end
			local sg=g:RandomSelect(tp,1)
			-- 将随机选中的对方手牌除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己场上表侧表示的「冰结界」同调怪兽
function c6075533.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x2f) and c:IsType(TYPE_SYNCHRO)
end
-- ②号效果的发动条件检测
function c6075533.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象中是否存在自己场上的「冰结界」同调怪兽，且该效果可以被无效
	return tg and tg:IsExists(c6075533.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- ②号效果的处理函数
function c6075533.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该发动效果无效
	Duel.NegateEffect(ev)
end
