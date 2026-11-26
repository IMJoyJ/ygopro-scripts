--アルカナスプレッド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。
-- ●表：从卡组把1只4星以下的「秘仪之力」怪兽特殊召唤。
-- ●里：把持有进行投掷硬币效果的1只怪兽从自己墓地特殊召唤。
-- ②：把墓地的这张卡除外才能发动。把持有进行投掷硬币效果的1张卡从自己墓地加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名记述以及共用1回合1次次数的①②两个效果。
function s.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「光之结界」。
	aux.AddCodeList(c,73206827)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。●表：从卡组把1只4星以下的「秘仪之力」怪兽特殊召唤。●里：把持有进行投掷硬币效果的1只怪兽从自己墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。把持有进行投掷硬币效果的1张卡从自己墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价为将墓地的这张卡表侧除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片是否为可特殊召唤的4星以下「秘仪之力」怪兽。
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：检查卡片是否为可特殊召唤且持有投掷硬币效果的怪兽。
function s.spfilter2(c,e,tp)
	-- 判断卡片效果是否带有硬币标记且可以被特殊召唤。
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数：检查自己怪兽区空位及卡组「表」或墓地「里」存在可特招怪兽，并设置投掷硬币操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己怪兽区至少有1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在可特殊召唤的4星以下「秘仪之力」怪兽。
		and (Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 或者自己墓地是否存在可特殊召唤且持有投掷硬币效果的怪兽。
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)) end
	-- 设置操作信息：预计自己进行1次投掷硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ①效果的处理函数：判定硬币结果（己方场地区域有光之结界时自选里表），并分别从卡组或墓地特殊召唤对应怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local res=-1
	-- 检查自己场地区域是否存在生效的「光之结界」。
	if Duel.IsEnvironment(73206827,tp,LOCATION_FZONE) then
		-- 处理时检查自己怪兽区是否有空位，没有则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 检查「表」效果是否可适用：确认自己卡组存在可特招的4星以下「秘仪之力」怪兽。
		local b1=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查「里」效果是否可适用：确认自己墓地存在不受王家长眠之谷影响且可特招的带投掷硬币效果怪兽。
		local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		if b1 and not b2 then
			-- 若仅「表」效果可适用，向对方提示己方选择了正面（表）效果。
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 若仅「里」效果可适用，向对方提示己方选择了反面（里）效果。
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 若里表效果均可适用，让己方玩家从中选择适用正面（1）或反面（0）。
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	else
		-- 若自己场地区域没有「光之结界」，则由己方投掷1次硬币决定正反面结果。
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 适用「表」效果时检查自己怪兽区是否有空位，没有则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己卡组选择1只4星以下的「秘仪之力」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选的「秘仪之力」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 适用「里」效果时检查自己怪兽区是否有空位，没有则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只不受王家长眠之谷影响且持有投掷硬币效果的怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选的持有投掷硬币效果的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：检查卡片是否为可加入手卡且持有投掷硬币效果的卡。
function s.thfilter(c)
	-- 判断卡片效果是否带有硬币标记且能够加入手卡。
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- ②效果的目标处理函数：检查自己墓地除这张卡外是否存在可加入手卡的带投掷硬币效果的卡，并设置回手卡操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己墓地除这张卡外存在至少1张符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息：预计从自己墓地把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理函数：从自己墓地选1张不受王家长眠之谷影响且持有投掷硬币效果的卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，引导玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张不受王家长眠之谷影响且持有投掷硬币效果的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡以效果加入自己手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
