--ENシャッフル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己场上1只「元素英雄」怪兽或者「新空间侠」怪兽回到持有者卡组，和那只怪兽卡名不同的1只「元素英雄」怪兽或者「新空间侠」怪兽从卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己墓地选「元素英雄」怪兽和「新空间侠」怪兽各1只或者「元素英雄 新宇侠」1只回到卡组。那之后，自己从卡组抽1张。
function c10186633.initial_effect(c)
	-- 为卡片注册「元素英雄 新宇侠」的卡片代码，用于判定效果中涉及的卡片
	aux.AddCodeList(c,89943723)
	-- 为卡片注册系列代码0x3008（新空间侠），用于判定怪兽是否属于该系列
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
	-- 设置成本为将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c10186633.drtg)
	e2:SetOperation(c10186633.drop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：选择自己场上符合条件的怪兽送回卡组
function c10186633.tdfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x3008,0x1f) and c:IsType(TYPE_MONSTER)
		-- 检查目标怪兽能否返回卡组，并确保送回后场上仍有空位用于特召
		and c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组中是否存在满足条件的不同名称怪兽可供特殊召唤
		and Duel.IsExistingMatchingCard(c10186633.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 定义筛选条件：从卡组特殊召唤符合条件且与送回怪兽不同名的怪兽
function c10186633.spfilter(c,e,tp,code)
	return c:IsSetCard(0x3008,0x1f) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果①的目标阶段处理函数
function c10186633.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的场上怪兽可以送回卡组
	if chk==0 then return Duel.IsExistingMatchingCard(c10186633.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置操作信息：将1张卡送回主怪兽区
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果①的实际操作处理函数
function c10186633.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 让玩家选择满足条件的场上怪兽并获取其引用
	local tc=Duel.SelectMatchingCard(tp,c10186633.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local code=tc:GetCode()
	-- 将选定怪兽送入卡组，并确认其确实进入卡组或额外卡组
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 确认场上仍有空位可用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 让玩家从卡组选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c10186633.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作，将选中的怪兽以表侧攻击表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义筛选条件：选择墓地中符合条件的怪兽送回卡组
function c10186633.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsSetCard(0x3008,0x1f) or c:IsCode(89943723))
end
-- 定义组合检查条件：验证所选怪兽组合是否合法
function c10186633.gcheck(g)
	-- 判断组合是否为单独的新宇侠，或是包含新空间侠和元素英雄的组合
	return #g==1 and g:GetFirst():IsCode(89943723) or aux.gfcheck(g,Card.IsSetCard,0x3008,0x1f)
end
-- 定义效果②的目标阶段处理函数
function c10186633.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否能够抽1张卡
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		-- 获取墓地中所有满足条件的怪兽集合
		local g=Duel.GetMatchingGroup(c10186633.filter,tp,LOCATION_GRAVE,0,nil)
		return g:CheckSubGroup(c10186633.gcheck,1,2)
	end
	-- 设置操作信息：将1张卡从墓地送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果②的实际操作处理函数
function c10186633.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受王家长眠之谷影响外的所有满足条件的墓地怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10186633.filter),tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,c10186633.gcheck,false,1,2)
	if sg then
		-- 显示被选作对象的怪兽动画效果
		Duel.HintSelection(sg)
		-- 将选中的怪兽送入卡组，并确认操作成功
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			-- 获取刚刚被操作的卡片组
			local og=Duel.GetOperatedGroup()
			if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
			-- 中断当前效果链，使后续抽卡独立处理
			Duel.BreakEffect()
			-- 使玩家抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
