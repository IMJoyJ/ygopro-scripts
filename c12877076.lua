--宝玉神覚醒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把手卡1只「究极宝玉神」怪兽给对方观看，从以下效果选择1个发动。或者在自己场上有「究极宝玉神」怪兽存在的场合，可以从以下效果选择1个或者两方发动。
-- ●从卡组选1张「桥梁」卡或者「飞越虹桥」加入手卡或送去墓地。
-- ●选自己的手卡·卡组·墓地1只「宝玉兽」怪兽或者自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册1回合只能发动1张的魔法发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以把手卡1只「究极宝玉神」怪兽给对方观看，从以下效果选择1个发动。或者在自己场上有「究极宝玉神」怪兽存在的场合，可以从以下效果选择1个或者两方发动。●从卡组选1张「桥梁」卡或者「飞越虹桥」加入手卡或送去墓地。●选自己的手卡·卡组·墓地1只「宝玉兽」怪兽或者自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查手卡中是否存在未公开的「究极宝玉神」怪兽。
function s.cfilter1(c)
	return c:IsSetCard(0x2034) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 过滤条件：检查自己怪兽区是否存在表侧表示的「究极宝玉神」怪兽。
function s.cfilter2(c)
	return c:IsSetCard(0x2034) and c:IsFaceup()
end
-- 发动代价标记函数：将Label设为100以标识已通过Cost阶段检测。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：检查卡片是否为可加入手卡或送去墓地的「桥梁」卡或「飞越虹桥」。
function s.hfilter(c)
	return (c:IsSetCard(0x187) or c:IsCode(40854824)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 过滤条件：检查卡片是否为原卡类为怪兽、位于魔陷区时表侧且可特招的「宝玉兽」卡。
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsSetCard(0x1034)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_SZONE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数：检查发动前提（手卡展示或场上存在）及子效果可行性，展示手卡并让玩家选择适用选项。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在可给对方观看的「究极宝玉神」怪兽。
	local c1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查自己怪兽区是否存在表侧表示的「究极宝玉神」怪兽。
	local c2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	-- 检查卡组是否存在可加入手卡或送去墓地的「桥梁」卡或「飞越虹桥」。
	local b1=Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己怪兽区是否存在可用于特殊召唤的空位。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地·魔陷区是否存在可特殊召唤的「宝玉兽」怪兽或怪兽卡。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return (c1 or c2) and (b1 or b2)
	end
	e:SetLabel(0)
	if not c2 then
		-- 发送提示信息，引导玩家选择要给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从自己手卡选择1只未公开的「究极宝玉神」怪兽。
		local rg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 将所选「究极宝玉神」怪兽给对方确认观看。
		Duel.ConfirmCards(1-tp,rg)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
	end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)  --"卡组检索"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)  --"特殊召唤"
		opval[off-1]=2
		off=off+1
	end
	if b1 and b2 and c2 then
		ops[off]=aux.Stringid(id,2)  --"选择两方"
		opval[off-1]=3
	end
	-- 让己方从可用选项中选择要发动的1个或两方效果，并记录所选编号。
	local op=opval[Duel.SelectOption(tp,table.unpack(ops))]
	e:SetLabel(op)
	e:SetCategory(0)
	if op&1>0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	end
	if op&2>0 then
		e:SetCategory(e:GetCategory()|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECK_SPSUMMON)
		-- 当选择了特殊召唤分支时，设置预计从手卡·卡组·墓地·魔陷区特殊召唤1只怪兽的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE)
	end
end
-- ①效果的处理函数：根据发动时选择的选项，依次执行「桥梁」/「飞越虹桥」检索或送墓，以及「宝玉兽」特殊召唤。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op&1>0 then
		-- 发送提示信息，引导玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从自己卡组选择1张「桥梁」卡或「飞越虹桥」。
		local tc=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 若所选卡可以加入手卡，且无法送墓或玩家选择加入手卡时进入加入手卡分支。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将所选卡以效果加入手卡，并记录实际处理数量。
			res=Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方确认。
			Duel.ConfirmCards(1-tp,tc)
		elseif tc then
			-- 将所选卡以效果送去墓地，并记录实际处理数量。
			res=Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
	-- 若选择了特殊召唤分支且自己怪兽区仍有空位，则执行特殊召唤处理。
	if op&2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地·魔陷区选1只不受王家长眠之谷影响的「宝玉兽」怪兽或怪兽卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil,e,tp)
		if #g==0 then return end
		-- 若同时适用两方效果且前一步操作成功，则中断当前效果以示不同时处理。
		if op==3 and res~=0 then Duel.BreakEffect() end
		-- 将所选「宝玉兽」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
