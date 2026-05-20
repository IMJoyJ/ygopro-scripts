--竜星の九支
-- 效果：
-- ①：自己场上有「龙星」卡存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。那之后，选这张卡以外的自己场上1张「龙星」卡破坏。
function c57831349.initial_effect(c)
	-- ①：自己场上有「龙星」卡存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。那之后，选这张卡以外的自己场上1张「龙星」卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c57831349.condition)
	e1:SetTarget(c57831349.target)
	e1:SetOperation(c57831349.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「龙星」卡
function c57831349.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e)
end
-- 发动条件：检查自己场上是否存在「龙星」卡，且连锁中的效果为怪兽效果或魔陷的发动，并且该发动可以被无效
function c57831349.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「龙星」卡
	return Duel.IsExistingMatchingCard(c57831349.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查被连锁的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 效果的目标处理：进行“无效并回到卡组”的合法性检查，并设置无效与回卡组的操作信息
function c57831349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，使用通用函数检查被连锁的效果是否可以被无效并送回卡组
	if chk==0 then return aux.ndcon(tp,re) end
	-- 设置操作信息：无效该发动的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 若被连锁的卡与自身效果有关联，则设置操作信息：将该卡送回持有者卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 过滤条件：自己场上表侧表示的「龙星」卡（用于后续破坏效果）
function c57831349.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e)
end
-- 效果的处理：无效发动并使卡片回到卡组，之后选择自己场上1张「龙星」卡破坏
function c57831349.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 无效该连锁的发动，并确认该卡与自身效果有关联
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将该卡送回持有者卡组（或额外卡组）并洗牌，确认其成功回到卡组或额外卡组
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 获取自己场上除这张卡（龙星的九支）以外的所有表侧表示的「龙星」卡
			local g=Duel.GetMatchingGroup(c57831349.desfilter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续的破坏处理与前方的回卡组处理不视为同时进行（会造成错时点）
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 破坏选中的「龙星」卡
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
