--ブレイク・ザ・シール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的卡组·墓地把1张「破除封印」在自己场上表侧表示放置。
-- ●把包含这张卡的自己场上2张表侧表示的「破除封印」送去墓地才能发动。从卡组把1只「被封印」怪兽加入手卡。
-- ②：场上的这张卡被破坏的场合，把手卡最多5只「被封印」怪兽给对方观看才能发动。那个数量的对方场上的卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果：包含发动、放置同名卡、送墓检索、被破坏时弹卡四个效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●从自己的卡组·墓地把1张「破除封印」在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"同名卡表侧放置"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.totg)
	e2:SetOperation(s.toop)
	c:RegisterEffect(e2)
	-- ●把包含这张卡的自己场上2张表侧表示的「破除封印」送去墓地才能发动。从卡组把1只「被封印」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被破坏的场合，把手卡最多5只「被封印」怪兽给对方观看才能发动。那个数量的对方场上的卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon2)
	e4:SetCost(s.thcost2)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：卡名为「破除封印」且未被限制放置、在场上唯一存在。
function s.tofilter(c,tp)
	return c:IsCode(id) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 放置效果的发动准备与合法性检查。
function s.totg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的卡组或墓地是否存在可以放置的「破除封印」。
		and Duel.IsExistingMatchingCard(s.tofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 放置效果的处理：从卡组或墓地选择1张「破除封印」在场上表侧表示放置。
function s.toop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否仍有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组或墓地中选择1张不受「王家长眠之谷」影响的「破除封印」。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tofilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	-- 若选择成功，则将其在自己的魔法与陷阱区域表侧表示放置。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 过滤条件：自己场上表侧表示且可以作为cost送去墓地的「破除封印」。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(id) and c:IsAbleToGraveAsCost()
end
-- 检索效果的发动代价处理：将包含这张卡的2张表侧表示的「破除封印」送去墓地。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否能送去墓地，且场上是否存在另一张可送去墓地的「破除封印」。
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上另一张「破除封印」并与自身组合成卡片组。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)+c
	-- 将选中的2张「破除封印」作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的「被封印」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与效果分类注册。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在「被封印」怪兽，且此卡在场上处于效果适用状态。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 设置连锁运营信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组把1只「被封印」怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只「被封印」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 触发条件：此卡原本在场上存在。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手牌中未公开的「被封印」怪兽。
function s.cpfilter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 弹卡效果的发动代价处理：展示手牌中最多5只「被封印」怪兽。
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌中所有未公开的「被封印」怪兽。
	local g=Duel.GetMatchingGroup(s.cpfilter,tp,LOCATION_HAND,0,nil)
	-- 获取对方场上可以回到手牌的卡片数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if ct>5 then ct=5 end
	if chk==0 then return #g>0 and ct>0 end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:Select(tp,1,ct,nil)
	-- 给对方玩家确认展示的「被封印」怪兽。
	Duel.ConfirmCards(1-tp,sg)
	-- 重新洗切手牌。
	Duel.ShuffleHand(tp)
	e:SetLabel(#sg)
end
-- 弹卡效果的发动准备与效果分类注册。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以回到手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 获取对方场上所有可以回到手牌的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁运营信息：对方场上的指定数量卡片回到手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,ct,0,0)
end
-- 弹卡效果的处理：使对应数量的对方场上的卡回到手牌。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择与展示数量相同数量的对方场上的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	if g:GetCount()>0 then
		-- 选中卡片并显示被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 将选中的对方场上的卡送回持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
