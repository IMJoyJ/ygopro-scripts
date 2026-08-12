--ラビュリンス・セッティング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的卡以及除外的自己的卡之中以「拉比林斯迷宫布置」以外的2张「拉比林斯迷宫」魔法·陷阱卡为对象才能发动。那些卡回到卡组。并且，自己场上有恶魔族怪兽存在的场合，可以再从卡组选回去数量的「拉比林斯迷宫」卡以外的通常陷阱卡在自己场上盖放（同名卡最多1张）。
function c69895264.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地的卡以及除外的自己的卡之中以「拉比林斯迷宫布置」以外的2张「拉比林斯迷宫」魔法·陷阱卡为对象才能发动。那些卡回到卡组。并且，自己场上有恶魔族怪兽存在的场合，可以再从卡组选回去数量的「拉比林斯迷宫」卡以外的通常陷阱卡在自己场上盖放（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,69895264+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c69895264.target)
	e1:SetOperation(c69895264.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地或表侧除外的、「拉比林斯迷宫布置」以外的「拉比林斯迷宫」魔法·陷阱卡，且能回到卡组
function c69895264.tdfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsSetCard(0x17e) and not c:IsCode(69895264) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择与处理：检查并选择自己墓地或除外状态的2张「拉比林斯迷宫」魔陷作为对象，并设置效果分类为回卡组
function c69895264.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c69895264.tdfilter(chkc) end
	-- 检查自己墓地及除外的卡中是否存在至少2张满足条件的「拉比林斯迷宫」魔陷
	if chk==0 then return Duel.IsExistingTarget(c69895264.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择2张满足条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c69895264.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)
	-- 设置效果处理信息：将选中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理：将作为对象的卡送回卡组，若自己场上有恶魔族怪兽存在，则可以再从卡组将对应数量的「拉比林斯迷宫」以外的通常陷阱卡在场上盖放
function c69895264.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍有关联的对象卡送回持有者卡组并洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		-- 获取卡组中所有满足盖放条件的「拉比林斯迷宫」以外的通常陷阱卡
		local sg=Duel.GetMatchingGroup(c69895264.stfilter,tp,LOCATION_DECK,0,nil)
		-- 获取自己场上魔法与陷阱区域的空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- 检查是否有卡成功回到卡组，且自己场上是否存在表侧表示的恶魔族怪兽
		if ct>0 and Duel.IsExistingMatchingCard(c69895264.demfilter,tp,LOCATION_MZONE,0,1,nil)
			and sg:GetClassCount(Card.GetCode)>=ct and ft>=ct
			-- 询问玩家是否选择从卡组将通常陷阱卡盖放
			and Duel.SelectYesNo(tp,aux.Stringid(69895264,0)) then  --"是否选卡盖放？"
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从满足条件的卡中选择与回到卡组数量相同、且卡名各不相同的卡片组
			local stg=sg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
			-- 将选择的通常陷阱卡在自己场上盖放
			Duel.SSet(tp,stg)
		end
	end
end
-- 过滤条件：自己场上表侧表示的恶魔族怪兽
function c69895264.demfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 过滤条件：卡组中「拉比林斯迷宫」以外的、可以盖放的通常陷阱卡
function c69895264.stfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsSetCard(0x17e) and c:IsSSetable()
end
