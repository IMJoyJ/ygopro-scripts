--ENシャッフル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己场上1只「元素英雄」怪兽或者「新空间侠」怪兽回到持有者卡组，和那只怪兽卡名不同的1只「元素英雄」怪兽或者「新空间侠」怪兽从卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己墓地选「元素英雄」怪兽和「新空间侠」怪兽各1只或者「元素英雄 新宇侠」1只回到卡组。那之后，自己从卡组抽1张。
function c10186633.initial_effect(c)
	-- 将「元素英雄 新宇侠」注册为本卡的效果相关卡
	aux.AddCodeList(c,89943723)
	-- 将「元素英雄」系列怪兽注册为本卡的效果相关卡
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：选自己场上1只「元素英雄」怪兽或者「新空间侠」怪兽回到持有者卡组，和那只怪兽卡名不同的1只「元素英雄」怪兽或者「新空间侠」怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10186633)
	e1:SetTarget(c10186633.sptg)
	e1:SetOperation(c10186633.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己墓地选「元素英雄」怪兽和「新空间侠」怪兽各1只或者「元素英雄 新宇侠」1只回到卡组。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,10186634)
	-- 将墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c10186633.drtg)
	e2:SetOperation(c10186633.drop)
	c:RegisterEffect(e2)
end
-- 用于返回卡组并特殊召唤的场上怪兽的过滤条件
function c10186633.tdfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x3008,0x1f) and c:IsType(TYPE_MONSTER)
		-- 判定怪兽是否可以返回卡组，且该怪兽离开场后自己场上有可用的怪兽区域
		and c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		-- 判定自己卡组是否存在可以特殊召唤的其他卡名怪兽
		and Duel.IsExistingMatchingCard(c10186633.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 用于从卡组特殊召唤的怪兽的过滤条件
function c10186633.spfilter(c,e,tp,code)
	return c:IsSetCard(0x3008,0x1f) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①的效果的发动准备与操作信息设置
function c10186633.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10186633.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置操作信息：将1只场上的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：选自己场上1只怪兽回到持有者卡组，并从卡组特殊召唤1只与之卡名不同的怪兽
function c10186633.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只满足过滤条件的「元素英雄」或「新空间侠」怪兽
	local tc=Duel.SelectMatchingCard(tp,c10186633.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local code=tc:GetCode()
	-- 若成功将选择的怪兽送回卡组或额外卡组
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 且此时自己场上有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只卡名不同的「元素英雄」或「新空间侠」怪兽
		local g=Duel.SelectMatchingCard(tp,c10186633.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 用于从墓地返回卡组的怪兽的过滤条件
function c10186633.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsSetCard(0x3008,0x1f) or c:IsCode(89943723))
end
-- 用于检查选中的卡片组合是否满足返回卡组条件的辅助函数
function c10186633.gcheck(g)
	-- 检查选择的卡片数量是否为1张且是「元素英雄 新宇侠」，或者为各含「元素英雄」和「新空间侠」的2张卡
	return #g==1 and g:GetFirst():IsCode(89943723) or aux.gfcheck(g,Card.IsSetCard,0x3008,0x1f)
end
-- ②的效果的发动准备与操作信息设置
function c10186633.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判定自己是否可以抽卡
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		-- 获取自己墓地所有满足条件的怪兽
		local g=Duel.GetMatchingGroup(c10186633.filter,tp,LOCATION_GRAVE,0,nil)
		return g:CheckSubGroup(c10186633.gcheck,1,2)
	end
	-- 设置操作信息：将墓地的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：玩家从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②的效果处理：将墓地符合条件的卡送回卡组，之后洗牌并抽1张卡
function c10186633.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取墓地中不受「王家长眠之谷」影响的符合过滤条件的卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10186633.filter),tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,c10186633.gcheck,false,1,2)
	if sg then
		-- 显示被选中卡片送回卡组的动画效果
		Duel.HintSelection(sg)
		-- 若成功将选中的卡片送回卡组
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			-- 获取实际被操作并送回卡组/额外卡组的卡片组
			local og=Duel.GetOperatedGroup()
			if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
			-- 将自己的卡组洗牌
			Duel.ShuffleDeck(tp)
			-- 中断当前效果，使后续的抽卡处理不与返回卡组同时处理
			Duel.BreakEffect()
			-- 从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
