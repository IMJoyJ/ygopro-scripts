--混沌の魔王－スカル・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以除这张卡外的包含有「光与暗的仪式」的卡名记述的卡的自己·对方的墓地·除外状态（表侧）的卡合计3张为对象才能发动。那些卡用喜欢的顺序回到卡组下面，这张卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从手卡·卡组把1张仪式魔法卡送去墓地才能发动。把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册这张卡与记述「光与暗的仪式」的卡名关联，并在手卡/墓地可发动的①的特招·回卡组效果，以及被送去墓地时发动的②的仪式检索效果
function s.initial_effect(c)
	-- 记录本卡在规则上与卡名「光与暗的仪式」(33599853)相关联
	aux.AddCodeList(c,33599853)
	-- ①：这张卡在手卡·墓地存在的场合，以除这张卡外的包含有「光与暗的仪式」的卡名记述的卡的自己·对方的墓地·除外状态（表侧）的卡合计3张为对象才能发动。那些卡用喜欢的顺序回到卡组下面，这张卡特殊召唤。
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
	-- ②：这张卡被送去墓地的场合，从手卡·卡组把1张仪式魔法卡送去墓地才能发动。把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡。
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
-- 过滤自己或对方的墓地/除外状态下可返回卡组并能作为效果对象的卡
function s.tdfilter(c,e)
	return c:IsFaceupEx() and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 过滤记述有「光与暗的仪式」的卡
function s.cfilter(c)
	-- 检查该卡是否记述了「光与暗的仪式」
	return aux.IsCodeListed(c,33599853)
end
-- 检查卡组组中是否至少存在1张卡记述有「光与暗的仪式」
function s.gcheck(g,tp)
	return g:IsExists(s.cfilter,1,nil)
end
-- ①效果的发动准备与合法性检查：确认自己场上有可召唤的空格、这张卡可以特殊召唤，并且双方墓地或除外卡中存在合计3张记述了「光与暗的仪式」的可返回卡组的对象卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 获取双方墓地或除外状态下符合返回卡组条件且不是本卡自身的所有卡片
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,c,e)
	-- 效果发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,3,3) end
	-- 提示玩家选择要返回卡组的对象卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 把选中的3张卡片设为本效果的连锁对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	-- 设置效果处理信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理：将作为对象的3张卡放入卡组底端，并将这张卡从手卡或墓地特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中不受墓地限制卡影响且仍然关联的目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	if #tg>0 then
		-- 将目标卡片置于持有者卡组的最下方（顺序由玩家选择）
		local ct=aux.PlaceCardsOnDeckBottom(tp,tg)
		if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 检查这张卡是否仍关联当前连锁，且不受王家长眠之谷限制
			and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 中断当前效果处理过程，以使之后的特殊召唤与回卡组视为不同时处理
			Duel.BreakEffect()
			-- 将这张卡以表侧表示特殊召唤到发动玩家的场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤手卡或卡组中作为Cost送入墓地的仪式魔法卡，且卡组中存有该魔法卡记述的仪式怪兽
function s.cfilter2(c,tp)
	return c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在被选为代价的仪式魔法卡所记述的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
-- 过滤卡组中可以被检索并加入手牌的仪式怪兽
function s.thfilter(c,ec)
	-- 检查该仪式怪兽是否记述于作为代价的仪式魔法卡上，且可以加入手牌
	return aux.IsCodeListed(ec,c:GetCode()) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and c:IsAbleToHand()
end
-- ②效果的发动代价：从手卡或卡组将1张符合条件的仪式魔法卡送入墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时，检查手卡或卡组中是否存在可作为代价的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择要作为代价送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张符合条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 将选中的仪式魔法卡作为发动代价送入墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- 把送入墓地的仪式魔法卡设为效果的对象以供后续处理参考
	Duel.SetTargetCard(g:GetFirst())
end
-- ②效果的发动准备与合法性检查：确认仪式魔法卡作为代价被成功送去墓地，并设置检索怪兽的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置效果处理信息：从卡组检索1只仪式怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1只在那张送入墓地的仪式魔法卡上有卡名记述的仪式怪兽加入手牌并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为发动代价送去墓地的仪式魔法卡
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要加入手牌的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只符合条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入到玩家的手牌中
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的怪兽卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
