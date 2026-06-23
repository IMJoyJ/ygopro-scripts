--宝玉神覚醒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把手卡1只「究极宝玉神」怪兽给对方观看，从以下效果选择1个发动。或者在自己场上有「究极宝玉神」怪兽存在的场合，可以从以下效果选择1个或者两方发动。
-- ●从卡组选1张「桥梁」卡或者「飞越虹桥」加入手卡或送去墓地。
-- ●选自己的手卡·卡组·墓地1只「宝玉兽」怪兽或者自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
local s,id,o=GetID()
-- 注册卡牌的初始效果，设置为发动时点、自由连锁、发动次数限制为1次、设置标签为0、设置费用函数、设置目标函数、设置效果处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
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
-- 过滤函数：检查手牌中是否存在未公开的「究极宝玉神」怪兽
function s.cfilter1(c)
	return c:IsSetCard(0x2034) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 过滤函数：检查场上是否存在「究极宝玉神」怪兽
function s.cfilter2(c)
	return c:IsSetCard(0x2034) and c:IsFaceup()
end
-- 费用函数：设置标签为100，表示已支付费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数：检查卡组中是否存在「桥梁」卡或「飞越虹桥」卡
function s.hfilter(c)
	return (c:IsSetCard(0x187) or c:IsCode(40854824)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 过滤函数：检查手卡·卡组·墓地或魔法与陷阱区域中是否存在「宝玉兽」怪兽或「宝玉兽」魔法卡
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsSetCard(0x1034)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_SZONE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：检查是否满足发动条件，包括是否满足条件1（手牌有「究极宝玉神」怪兽）或条件2（场上存在「究极宝玉神」怪兽），以及是否满足效果1（检索卡组）或效果2（特殊召唤），并根据选择设置效果分类
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件1的卡
	local c1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查场上是否存在满足条件2的卡
	local c2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	-- 检查卡组中是否存在满足条件1的卡
	local b1=Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查玩家场上是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地或魔法与陷阱区域中是否存在满足条件2的卡
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return (c1 or c2) and (b1 or b2)
	end
	e:SetLabel(0)
	if not c2 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择满足条件1的卡
		local rg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 确认对方查看所选卡
		Duel.ConfirmCards(1-tp,rg)
		-- 洗切玩家手牌
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
	-- 根据玩家选择的效果选项设置标签
	local op=opval[Duel.SelectOption(tp,table.unpack(ops))]
	e:SetLabel(op)
	e:SetCategory(0)
	if op&1>0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	end
	if op&2>0 then
		e:SetCategory(e:GetCategory()|CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE)
	end
end
-- 效果处理函数：根据选择的效果选项执行检索或特殊召唤
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op&1>0 then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择满足条件1的卡
		local tc=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 判断是否选择将卡送入手牌或墓地
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将卡送入手牌
			res=Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方查看所选卡
			Duel.ConfirmCards(1-tp,tc)
		elseif tc then
			-- 将卡送入墓地
			res=Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
	-- 判断是否满足特殊召唤条件
	if op&2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地或魔法与陷阱区域中选择满足条件2的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil,e,tp)
		if #g==0 then return end
		-- 如果选择两方效果且已执行检索效果，则中断当前效果
		if op==3 and res~=0 then Duel.BreakEffect() end
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
