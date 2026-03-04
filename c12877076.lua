--宝玉神覚醒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把手卡1只「究极宝玉神」怪兽给对方观看，从以下效果选择1个发动。或者在自己场上有「究极宝玉神」怪兽存在的场合，可以从以下效果选择1个或者两方发动。
-- ●从卡组选1张「桥梁」卡或者「飞越虹桥」加入手卡或送去墓地。
-- ●选自己的手卡·卡组·墓地1只「宝玉兽」怪兽或者自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- ①：可以把手卡1只「究极宝玉神」怪兽给对方观看，从以下效果选择1个发动。或者在自己场上有「究极宝玉神」怪兽存在的场合，可以从以下效果选择1个或者两方发动。
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
-- 过滤手卡中未公开的「究极宝玉神」怪兽
function s.cfilter1(c)
	return c:IsSetCard(0x2034) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 过滤自己场上表侧表示的「究极宝玉神」怪兽
function s.cfilter2(c)
	return c:IsSetCard(0x2034) and c:IsFaceup()
end
-- 设置发动费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤卡组中「桥梁」卡或者「飞越虹桥」
function s.hfilter(c)
	return (c:IsSetCard(0x187) or c:IsCode(40854824)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 过滤可以特殊召唤的「宝玉兽」怪兽或怪兽卡
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsSetCard(0x1034)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_SZONE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时点
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在未公开的「究极宝玉神」怪兽
	local c1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查自己场上是否存在表侧表示的「究极宝玉神」怪兽
	local c2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	-- 检查卡组是否存在「桥梁」卡或「飞越虹桥」
	local b1=Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否存在空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在「宝玉兽」怪兽或怪兽卡
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return (c1 or c2) and (b1 or b2)
	end
	e:SetLabel(0)
	if not c2 then
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		-- 选择手卡中符合条件的「究极宝玉神」怪兽
		local rg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,rg)
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
	end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if b1 and b2 and c2 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
	end
	-- 选择发动效果
	local op=opval[Duel.SelectOption(tp,table.unpack(ops))]
	e:SetLabel(op)
	e:SetCategory(0)
	if op&1>0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	end
	if op&2>0 then
		e:SetCategory(e:GetCategory()|CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息，用于特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE)
	end
end
-- 效果处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op&1>0 then
		-- 提示玩家选择要处理的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		-- 从卡组中选择符合条件的「桥梁」卡或「飞越虹桥」
		local tc=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 判断是否将卡加入手牌或送去墓地
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将卡加入手牌
			res=Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认所选的卡
			Duel.ConfirmCards(1-tp,tc)
		elseif tc then
			-- 将卡送去墓地
			res=Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
	-- 判断是否发动特殊召唤效果
	if op&2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择符合条件的「宝玉兽」怪兽或怪兽卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil,e,tp)
		if #g==0 then return end
		-- 中断当前效果处理
		if op==3 and res~=0 then Duel.BreakEffect() end
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
