--混沌の魔王－スカル・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以除这张卡外的包含有「光与暗的仪式」的卡名记述的卡的自己·对方的墓地·除外状态（表侧）的卡合计3张为对象才能发动。那些卡用喜欢的顺序回到卡组下面，这张卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从手卡·卡组把1张仪式魔法卡送去墓地才能发动。把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册卡名记载信息，并创建①效果（手卡·墓地的起动特殊召唤效果，1回合1次）和②效果（被送去墓地时的诱发选发检索效果，1回合1次）
function s.initial_effect(c)
	-- 记录这张卡上记载着「光与暗的仪式」（卡号33599853）的卡名
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
-- ①效果的对象过滤函数：这张卡须为表侧表示（含除外状态）、能够回到卡组且能成为这个效果的对象
function s.tdfilter(c,e)
	return c:IsFaceupEx() and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 判断这张卡的效果文本上是否记载着「光与暗的仪式」的卡名
function s.cfilter(c)
	-- 检测该卡的效果文本上是否记载着「光与暗的仪式」（卡号33599853）
	return aux.IsCodeListed(c,33599853)
end
-- 检查选择的卡组合中是否存在至少1张记载了「光与暗的仪式」卡名的卡
function s.gcheck(g,tp)
	return g:IsExists(s.cfilter,1,nil)
end
-- ①效果的目标函数：取得除这张卡外双方墓地·除外状态能回卡组的卡，检查场上是否有空格、这张卡能否特殊召唤以及能否选出3张满足条件的卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 取得除这张卡外的自己·对方的墓地·除外状态（表侧）中能够回到卡组、可作为效果对象的卡
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,c,e)
	-- 发动条件检测：自己的怪兽区域有可用空格、这张卡可以特殊召唤，且存在包含记载「光与暗的仪式」卡名的卡的3张组合
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,3,3) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 把选出的3张卡设置为本连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将把作为对象的卡合计3张返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	-- 设置操作信息：将把这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：取得仍与连锁关联且不受王家长眠之谷影响的对象卡，让它们用喜欢的顺序回到卡组下面；若成功回卡组且这张卡仍与连锁关联，则中断处理后把这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象中不受王家长眠之谷影响的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #tg>0 then
		-- 让那些卡用喜欢的顺序回到卡组下面，并记录实际返回的数量
		local ct=aux.PlaceCardsOnDeckBottom(tp,tg)
		if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 且这张卡仍与连锁关联、不受王家长眠之谷的影响
			and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 中断当前效果，使回卡组与特殊召唤视为不同时处理（特殊召唤另开时点）
			Duel.BreakEffect()
			-- 把这张卡从手卡·墓地以表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的代价过滤函数：这张卡须为仪式魔法卡、可以作为代价送去墓地，且卡组存在在它卡名有记述的可加入手卡的仪式怪兽
function s.cfilter2(c,tp)
	return c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL) and c:IsAbleToGraveAsCost()
		-- 且卡组中存在在那张仪式魔法卡有卡名记述的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
-- 检索目标过滤函数：这张仪式怪兽的卡名须记载在那张仪式魔法卡上，且能够加入手卡
function s.thfilter(c,ec)
	-- 检测该仪式怪兽的卡名是否记载在那张仪式魔法卡（ec）上，且是仪式怪兽并能加入手卡
	return aux.IsCodeListed(ec,c:GetCode()) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and c:IsAbleToHand()
end
-- ②效果的代价函数：检测手卡·卡组是否存在符合条件的仪式魔法卡，让玩家选择1张送去墓地作为代价，并将其设为对象以便后续检索
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测手卡·卡组是否存在能作为代价送去墓地、且对应仪式怪兽存在于卡组的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡·卡组选择1张符合条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 把选择的仪式魔法卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- 把送去墓地的那张仪式魔法卡设置为对象，供效果处理时参照其卡名记述
	Duel.SetTargetCard(g:GetFirst())
end
-- ②效果的目标函数：确认代价已检查，并设置操作信息为从卡组把1张卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息：将从卡组把1只仪式怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：取得代价送去墓地的仪式魔法卡，让玩家从卡组选择1只在那张卡有卡名记述的仪式怪兽，将其加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得作为代价送去墓地的那张仪式魔法卡
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只在代价的仪式魔法卡有卡名记述的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 把选择的仪式怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
