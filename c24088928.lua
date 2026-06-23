--混沌の魔王－スカル・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以除这张卡外的包含有「光与暗的仪式」的卡名记述的卡的自己·对方的墓地·除外状态（表侧）的卡合计3张为对象才能发动。那些卡用喜欢的顺序回到卡组下面，这张卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从手卡·卡组把1张仪式魔法卡送去墓地才能发动。把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 定义一个函数s.initial_effect(c)，用于注册卡片效果。
function s.initial_effect(c)
	-- 将33599853加入到该卡的CodeList中，表示记录了另一张卡名。
	aux.AddCodeList(c,33599853)
	-- 创建第一个Effect对象e1，并设置描述为“特殊召唤”，类别为返回卡组和特殊召唤，类型为起动效果，发动范围为手牌和墓地，具有取对象属性，限制每回合一次，目标函数为s.sptg，操作函数为s.spop，并将该Effect注册到卡片c上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建第二个Effect对象e2，并设置描述为“检索效果”，类别为检索和回手牌，类型为单次触发效果，具有延迟属性，触发条件为送入墓地，限制每回合一次（id+o），代价函数为s.thcost，目标函数为s.thtg，操作函数为s.thop，并将该Effect注册到卡片c上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数s.tdfilter(c,e)，用于判断卡片是否满足返回卡组的条件：表侧显示、可以送入卡组以及可以作为效果目标。
function s.tdfilter(c,e)
	return c:IsFaceupEx() and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 定义一个过滤函数s.cfilter(c)，用于判断卡片是否记录了代码33599853。
function s.cfilter(c)
	-- 返回aux.IsCodeListed(c,33599853)
	return aux.IsCodeListed(c,33599853)
end
-- 定义一个检查函数s.gcheck(g,tp)，用于判断组g中是否存在满足s.cfilter过滤器的卡片。
function s.gcheck(g,tp)
	return g:IsExists(s.cfilter,1,nil)
end
-- 定义特殊召唤的目标选择函数s.sptg，用于确定特殊召唤的条件和目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 使用Duel.GetMatchingGroup获取符合条件的墓地或除外区域的卡组。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,c,e)
	-- 检查玩家场上是否有可用的怪兽区域、当前卡是否可以特殊召唤以及满足条件的卡片数量是否大于等于3张。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,3,3) end
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 设置选定的卡片为目标卡。
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示将选定的卡片返回卡组以及特殊召唤当前卡片。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	-- 设置操作信息，表示将选定的卡片返回卡组以及特殊召唤当前卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义特殊召唤的操作函数s.spop，用于执行特殊召唤的实际操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的目标卡片。
	local tg=Duel.GetTargetsRelateToChain()
	if #tg>0 then
		-- 使用aux.PlaceCardsOnDeckBottom将选定的卡片放置在卡组底端。
		local ct=aux.PlaceCardsOnDeckBottom(tp,tg)
		if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 判断是否成功返回了卡片、目标卡片是否存在于卡组或额外卡组中、当前卡是否与连锁相关以及是否受到王家长眠之谷的影响，如果满足所有条件则中断效果并特殊召唤当前卡片。
			and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 中断当前效果。
			Duel.BreakEffect()
			-- 特殊召唤当前卡片。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义一个过滤函数s.cfilter2(c,tp)，用于判断卡片是否为仪式魔法卡且可以作为代价送入墓地，并且存在满足s.thfilter的卡片在卡组中。
function s.cfilter2(c,tp)
	return c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL) and c:IsAbleToGraveAsCost()
		-- 检查是否存在满足s.thfilter的卡片在卡组中
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
-- 定义一个过滤函数s.thfilter(c,ec)，用于判断卡片是否为仪式怪兽且可以加入手牌，并且记录了效果发动者的代码。
function s.thfilter(c,ec)
	-- 返回aux.IsCodeListed(ec,c:GetCode()) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and c:IsAbleToHand()
	return aux.IsCodeListed(ec,c:GetCode()) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and c:IsAbleToHand()
end
-- 定义代价函数s.thcost，用于确定送入墓地的卡片。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足s.cfilter2的卡片在手牌或卡组中。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择符合条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 将选定的卡片送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置目标卡为选中的卡片
	Duel.SetTargetCard(g:GetFirst())
end
-- 定义目标选择函数s.thtg，用于确定检索的条件和目标。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息，表示从卡组中检索一张卡片并加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义操作函数s.thop，用于执行检索实际的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择符合条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选定的卡片送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认选定的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
