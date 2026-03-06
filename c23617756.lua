--怒りの業火 エクゾード・フレイム
-- 效果：
-- 这个卡名在规则上也当作「艾格佐德」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有10星以上的「艾克佐迪亚」怪兽存在的场合才能发动。对方场上的卡全部破坏。
-- ②：可以把这个回合没有送去墓地的这张卡从墓地除外，从以下效果选择1个发动。
-- ●从自己的卡组·墓地把1只「被封印」怪兽加入手卡。
-- ●自己的墓地·除外状态的最多5只「被封印」怪兽回到卡组。
local s,id,o=GetID()
-- 注册两个效果：①破坏对方场上所有卡；②从墓地除外自己，选择检索或回收被封印怪兽的效果
function s.initial_effect(c)
	-- ①：自己场上有10星以上的「艾克佐迪亚」怪兽存在的场合才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：可以把这个回合没有送去墓地的这张卡从墓地除外，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	-- 效果发动时，若此卡在墓地则不能发动
	e2:SetCondition(aux.exccon)
	-- 效果发动时，将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上存在10星以上的艾克佐迪亚怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xde) and c:IsLevelAbove(10)
end
-- 判断是否满足①效果发动条件：自己场上有10星以上的艾克佐迪亚怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在10星以上的艾克佐迪亚怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备阶段：确认对方场上存在卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果发动条件：对方场上存在卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置①效果的处理信息：破坏对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的处理阶段：破坏对方场上所有卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 执行破坏操作
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 过滤条件：「被封印」怪兽且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤条件：「被封印」怪兽且可返回卡组
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果的发动准备阶段：判断是否可以检索或回收被封印怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在「被封印」怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	-- 检查自己墓地或除外区是否存在「被封印」怪兽
	local b2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择检索或回收选项：检索「被封印」怪兽/回收「被封印」怪兽
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"检索「被封印」怪兽/回收「被封印」怪兽"
	elseif b1 then
		-- 选择检索选项：检索「被封印」怪兽
		op=Duel.SelectOption(tp,aux.Stringid(id,1))  --"检索「被封印」怪兽"
	else
		-- 选择回收选项：回收「被封印」怪兽
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"回收「被封印」怪兽"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置②效果的处理信息：检索「被封印」怪兽
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_TODECK)
	end
end
-- ②效果的处理阶段：根据选择执行检索或回收操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择1张「被封印」怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择最多5张「被封印」怪兽返回卡组
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,5,nil)
		if g:GetCount()>0 then
			-- 向对方确认返回卡组的卡
			Duel.ConfirmCards(1-tp,g)
			-- 将选中的卡返回卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
