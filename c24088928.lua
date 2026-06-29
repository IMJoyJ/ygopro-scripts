--混沌の魔王－スカル・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以除这张卡外的包含有「光与暗的仪式」的卡名记述的卡的自己·对方的墓地·除外状态（表侧）的卡合计3张为对象才能发动。那些卡用喜欢的顺序回到卡组下面，这张卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从手卡·卡组把1张仪式魔法卡送去墓地才能发动。把1只在那张卡有卡名记述的仪式怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 注册此卡名记述关联、从手卡/墓地回收卡片特召自身的效果、以及送去墓地时通过送墓仪式魔法检索仪式怪兽的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「光与暗的仪式」（卡片密码：33599853）
	aux.AddCodeList(c,33599853)
	-- ①：这张卡在手卡·墓地存在的场合，以除这张卡外的包含有「光与暗的仪式」的卡名记述的卡的的自己·对方的墓地·除外状态（表侧）的卡合计3张为对象才能发动。那些卡用喜欢的顺序回到卡组下面，这张卡特殊召唤。
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
-- 可作为回收对象的自己或对方墓地/除外状态卡片的过滤条件
function s.tdfilter(c,e)
	return c:IsFaceupEx() and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 记述有「光与暗的仪式」卡名的卡片的过滤条件
function s.cfilter(c)
	-- 判断目标卡片是否记述有「光与暗的仪式」
	return aux.IsCodeListed(c,33599853)
end
-- 检查所选取的卡片组中是否包含至少1张记述有「光与暗的仪式」的卡片
function s.gcheck(g,tp)
	return g:IsExists(s.cfilter,1,nil)
end
-- 特殊召唤效果的发动准备与对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 获取自己与对方墓地和除外状态中所有满足回收条件的卡片
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,c,e)
	-- 检查自己场上是否有空闲怪兽区域、此卡能否特殊召唤且可选卡片组合是否足够
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,3,3) end
	-- 向玩家发送提示，请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 将选中的3张卡片作为效果的发动对象注册
	Duel.SetTargetCard(sg)
	-- 设置操作信息为将选中的3张卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	-- 设置操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁关联且未受墓地无效影响的作为对象的卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #tg>0 then
		-- 将选中的卡片按照玩家选择的顺序返回卡组最下方
		local ct=aux.PlaceCardsOnDeckBottom(tp,tg)
		if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 若有卡片成功返回卡组且此卡与连锁关联并正常存在
			and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 切断效果处理的连锁时点
			Duel.BreakEffect()
			-- 将此卡特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 可作为代价送去墓地且能检索后续仪式怪兽的仪式魔法过滤条件
function s.cfilter2(c,tp)
	return c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL) and c:IsAbleToGraveAsCost()
		-- 检查自己卡组中是否存在该仪式魔法所记述且可以加入手卡的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
-- 可检索并加入手卡的仪式怪兽的过滤条件
function s.thfilter(c,ec)
	-- 验证该仪式怪兽是否被仪式魔法卡名记述，且是否可加入手牌
	return aux.IsCodeListed(ec,c:GetCode()) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and c:IsAbleToHand()
end
-- 送墓仪式魔法以发动检索效果的代价执行
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡和卡组中是否存在满足代价条件的仪式魔法
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 向玩家发送提示，请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡或卡组选择1张满足条件的仪式魔法送去墓地
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 将选中的仪式魔法送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- 将该仪式魔法卡作为关联卡片进行标记
	Duel.SetTargetCard(g:GetFirst())
end
-- 检索效果的发动准备
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息为将1张怪兽卡从卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取代价阶段被送去墓地的仪式魔法卡
	local tc=Duel.GetFirstTarget()
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只被该仪式魔法卡名记述的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的仪式怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
