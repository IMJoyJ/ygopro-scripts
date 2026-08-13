--怒りの業火 エクゾード・フレイム
-- 效果：
-- 这个卡名在规则上也当作「艾格佐德」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有10星以上的「艾克佐迪亚」怪兽存在的场合才能发动。对方场上的卡全部破坏。
-- ②：可以把这个回合没有送去墓地的这张卡从墓地除外，从以下效果选择1个发动。
-- ●从自己的卡组·墓地把1只「被封印」怪兽加入手卡。
-- ●自己的墓地·除外状态的最多5只「被封印」怪兽回到卡组。
local s,id,o=GetID()
-- 创建并注册两个效果：e1为①效果（自己场上有10星以上「艾克佐迪亚」怪兽存在时，破坏对方场上的全部卡）；e2为②效果（从墓地除外自身，选择检索1只「被封印」怪兽加入手卡，或将最多5只「被封印」怪兽返回卡组）。两个效果各自1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次；自己场上有10星以上的「艾克佐迪亚」怪兽存在的场合才能发动；对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次；可以把这个回合没有送去墓地的这张卡从墓地除外，从以下效果选择1个发动。●从自己的卡组·墓地把1只「被封印」怪兽加入手卡。●自己的墓地·除外状态的最多5只「被封印」怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：这张卡不是本回合被送去墓地（即这个回合没有送去墓地）才能发动；若本回合曾送去墓地则不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：从墓地将这张卡除外作为COST，符合效果原文中“从墓地除外”的发动条件。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：筛选表侧表示、卡名含有「艾克佐迪亚」字段、等级10以上的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xde) and c:IsLevelAbove(10)
end
-- ①效果的发动条件：检查己方怪兽区域是否存在至少1只满足s.cfilter（表侧表示10星以上「艾克佐迪亚」怪兽）的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测以当前玩家tp视角，在己方主要怪兽区是否存在至少1张符合s.cfilter的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时的目标处理：在合法性检查时确认对方场上有卡可破坏；随后获取对方场上全部卡，并登记这些卡为破坏对象，数量为其总数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：对方场上必须存在至少1张卡，否则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部卡，作为本次破坏效果将要影响的对象集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：登记此次效果将破坏对方场上全部卡（数量为sg:GetCount()），供其他卡连锁时参考。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果处理：实际执行破坏，重新获取对方场上当前存在的全部卡并全部破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上当前存在的全部卡（因连锁中可能发生变化，所以不能沿用发动时取得的组）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏对方场上全部卡，将其送去墓地。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 过滤条件：卡名含有「被封印」字段的怪兽卡，并且可以加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤条件：卡名含有「被封印」字段的怪兽卡，处于表侧表示/可确认状态，并且可以返回卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果的发动目标：判断检索与回收两个选项是否可行，让玩家选择要执行的选项；用e:SetLabel记录选择结果，并据此设置效果分类与操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组或墓地是否存在至少1张可加入手牌的「被封印」怪兽，作为检索选项的可行性。
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	-- 检查己方墓地或除外区是否存在至少1张可返回卡组的「被封印」怪兽，作为回收选项的可行性。
	local b2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个选项均可用时，弹出选择菜单，让玩家选择“检索「被封印」怪兽”或“回收「被封印」怪兽”，op记录所选选项序号。
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"检索「被封印」怪兽/回收「被封印」怪兽"
	elseif b1 then
		-- 仅检索选项可用时，自动为玩家选择“检索「被封印」怪兽”，op为0。
		op=Duel.SelectOption(tp,aux.Stringid(id,1))  --"检索「被封印」怪兽"
	else
		-- 仅回收选项可用时，自动为玩家选择“回收「被封印」怪兽”；由于接口返回0，加1后op=1，以与检索分支区分。
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"回收「被封印」怪兽"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 选择检索时，登记操作信息：从己方卡组·墓地将1张卡加入手牌（目标不取对象，故targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_TODECK)
	end
end
-- ②效果处理：根据发动时记录的选项执行对应操作——若op=0则从卡组·墓地选1只「被封印」怪兽加入手牌；否则从墓地·除外选最多5只「被封印」怪兽返回卡组。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 向玩家发送选择提示消息：“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从己方卡组·墓地选择1只符合条件的「被封印」怪兽；通过NecroValleyFilter排除受“王家长眠之谷”影响而无法从墓地使用的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡以效果原因送去其持有者的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡，确认检索效果处理。
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 向玩家发送选择提示消息：“请选择要返回卡组的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从己方墓地·除外区选择1至5只符合条件的「被封印」怪兽；同样通过NecroValleyFilter处理墓地部分受王家长眠之谷影响的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,5,nil)
		if g:GetCount()>0 then
			-- 向对方玩家展示准备返回卡组的卡牌。
			Duel.ConfirmCards(1-tp,g)
			-- 将选中的卡以效果原因返回持有者卡组，并执行洗牌（SEQ_DECKSHUFFLE表示弹回卡组后洗牌）。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
