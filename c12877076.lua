--宝玉神覚醒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把手卡1只「究极宝玉神」怪兽给对方观看，从以下效果选择1个发动。或者在自己场上有「究极宝玉神」怪兽存在的场合，可以从以下效果选择1个或者两方发动。
-- ●从卡组选1张「桥梁」卡或者「飞越虹桥」加入手卡或送去墓地。
-- ●选自己的手卡·卡组·墓地1只「宝玉兽」怪兽或者自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数，为这张卡创建并注册一个魔法卡发动效果。
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
-- 过滤条件：用于判断手牌中是否存在未公开且属于「究极宝玉神」字段的怪兽，作为可否发动效果的条件之一。
function s.cfilter1(c)
	return c:IsSetCard(0x2034) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 过滤条件：用于判断自己场上是否存在表侧表示且属于「究极宝玉神」字段的怪兽，以决定能否同时选择两个效果。
function s.cfilter2(c)
	return c:IsSetCard(0x2034) and c:IsFaceup()
end
-- 发动前的cost处理：将效果标签设为100作为标记，表示已经进入发动流程，并返回true；实际展示手牌的动作在target阶段完成。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：用于检索卡组中满足『「桥梁」卡或「飞越虹桥」且能够加入手卡或送去墓地』的卡。
function s.hfilter(c)
	return (c:IsSetCard(0x187) or c:IsCode(40854824)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 过滤条件：用于选择可特殊召唤的「宝玉兽」怪兽，要求其原本类型为怪兽、属于「宝玉兽」字段，并且处于可特殊召唤的状态（不在魔陷区，或魔陷区表侧表示），同时满足苏生限制和特殊召唤条件。
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsSetCard(0x1034)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_SZONE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与选项设定：判断是否满足展示手牌或场上有究极宝玉神的条件，确认并展示手牌，接着让玩家选择执行哪个效果，设置对应标签和效果类别。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可给对方观看的「究极宝玉神」怪兽。
	local c1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查自己场上是否存在至少1只表侧表示的「究极宝玉神」怪兽。
	local c2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	-- 检查卡组中是否存在至少1张符合条件的「桥梁」卡或「飞越虹桥」。
	local b1=Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己主要怪兽区是否存在可用的空格。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查从卡组、手卡、墓地、魔陷区中是否存在至少1只可特殊召唤的「宝玉兽」怪兽。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return (c1 or c2) and (b1 or b2)
	end
	e:SetLabel(0)
	if not c2 then
		-- 弹出选择提示，要求玩家选择一张手牌用于给对方确认。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手牌中选择1只「究极宝玉神」怪兽。
		local rg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的手牌展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,rg)
		-- 展示后洗切手牌，避免对方通过手牌顺序获得额外信息。
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
	-- 弹出选项菜单，让玩家选择要执行的效果，并将对应选项值（1=检索/送墓，2=特殊召唤，3=两方）保存到效果标签中。
	local op=opval[Duel.SelectOption(tp,table.unpack(ops))]
	e:SetLabel(op)
	e:SetCategory(0)
	if op&1>0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	end
	if op&2>0 then
		e:SetCategory(e:GetCategory()|CATEGORY_SPECIAL_SUMMON)
		-- 预设置特殊召唤的操作信息，声明可能从卡组、手卡、墓地、魔陷区特殊召唤1只怪兽，供连锁判定和时点检测使用。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE)
	end
end
-- 效果处理时的执行函数：根据之前选择的选项，依次从卡组选「桥梁」/「飞越虹桥」加入手卡或送去墓地，并从指定区域特殊召唤「宝玉兽」怪兽；若选择两方则按顺序处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op&1>0 then
		-- 弹出选择提示，要求玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择1张符合条件的「桥梁」卡或「飞越虹桥」，并取得该卡。
		local tc=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 判断选中的卡是加入手卡还是送去墓地：若能加入手卡且（不能送去墓地或玩家选择加入手卡）则加入手卡，否则送去墓地。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的卡加入持有者手卡，并记录操作成功的结果。
			res=Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
		elseif tc then
			-- 将选中的卡送去墓地。
			res=Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
	-- 判断是否选择了特殊召唤效果，并且自己主要怪兽区仍有空位可进行特殊召唤。
	if op&2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出选择提示，要求玩家选择要特殊召唤的「宝玉兽」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组、手卡、墓地、魔陷区中选择1只可特殊召唤的「宝玉兽」怪兽，并通过王家长眠之谷的过滤，排除受其影响不能从墓地特殊召唤的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil,e,tp)
		if #g==0 then return end
		-- 当选择两方效果且第一项操作（加入手卡或送墓）成功时，中断当前效果处理，使后续特殊召唤视为不同的处理，以正确回应时点。
		if op==3 and res~=0 then Duel.BreakEffect() end
		-- 将选择的「宝玉兽」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
