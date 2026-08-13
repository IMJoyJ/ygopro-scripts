--糾罪巧θ’－「oknirIA」
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：墓地·除外状态的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
-- ③：这张卡反转的场合发动。对方的墓地·除外状态的最多3张卡回到卡组。
local s,id,o=GetID()
-- 初始化效果：为这张卡添加灵摆属性，注册灵摆①的放置纠罪指示物效果、灵摆②的检索效果、怪兽①的手卡里侧特殊召唤效果、怪兽②的检索效果、怪兽③的反转回卡组效果，并注册特殊召唤活动计数器
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（使其可以进行灵摆召唤及作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：墓地·除外状态的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.thcon2)
	e3:SetCost(s.thcost2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
	-- ③：这张卡反转的场合发动。对方的墓地·除外状态的最多3张卡回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"回卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
	-- 注册特殊召唤活动计数器，统计本回合特殊召唤表侧表示怪兽的次数，用于怪兽①效果的誓约判定
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：里侧表示的卡不计入计数（即里侧守备表示的特殊召唤不受誓约限制）
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆①效果处理：每次有怪兽反转时给这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆②效果的发动代价：检查并支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分
	Duel.PayLPCost(tp,900)
end
-- 过滤函数：「纠罪巧」卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 灵摆②效果的发动条件与目标设置：确认卡组有至少3张「纠罪巧」卡，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少3张可以加入手卡的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆②效果处理：从卡组选出3张「纠罪巧」卡给对方观看，对方从中随机选1张，那1张加入自己手卡，剩余回到卡组并洗切
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索卡组中全部可以加入手卡的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示自己选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 把选出的3张卡给对方观看
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 把对方随机选出的1张卡加入自己手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽①效果的发动条件确认：这张卡不在公开状态，且本回合未特殊召唤过表侧表示的怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 并且本回合没有特殊召唤过表侧表示的怪兽（活动计数为0）
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。②：墓地·除外状态的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把限制特殊召唤表示形式的誓约效果注册给自己（这个回合结束时重置）
	Duel.RegisterEffect(e1,tp)
end
-- 誓约限制函数：禁止表侧表示的特殊召唤（即只能用里侧守备表示特殊召唤）
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数：可以从手卡以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽①效果的发动条件与目标设置：未受「神圣光辉」影响、主要怪兽区有空位且手卡有可里侧守备表示特殊召唤的怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己是否受到「神圣光辉」（不能里侧守备表示特殊召唤）的影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 确认自己的主要怪兽区有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡存在可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽①效果处理：从手卡选1只怪兽里侧守备表示特殊召唤，若该怪兽原本处于公开状态则给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 主要怪兽区没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示自己选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选1只可以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 把选出的怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 把这张原本处于公开状态的卡给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽②效果的发动条件：对方发动了墓地·除外状态的卡的效果，且这张卡在怪兽区里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中发动效果的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_GRAVE+LOCATION_REMOVED)&loc~=0
		and e:GetHandler():IsFacedown()
end
-- 怪兽②效果的发动代价：把里侧表示的这张卡变成表侧守备表示
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把这张卡变成表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 过滤函数：「纠罪巧」卡且可以加入手卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 怪兽②效果的发动条件与目标设置：确认卡组存在可以加入手卡的「纠罪巧」卡，并设置加入手卡的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张可以加入手卡的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽②效果处理：从卡组选1张「纠罪巧」卡加入手卡，并给对方确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选1张可以加入手卡的「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选出的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽③效果的目标设置：取得对方墓地·除外状态可以回到卡组的卡，并设置回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方墓地·除外状态全部可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	-- 设置操作信息：把对方的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 怪兽③效果处理：选对方的墓地·除外状态最多3张卡，回到卡组并洗切
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方的墓地·除外状态选1~3张可以回到卡组的卡（过滤掉受王家长眠之谷影响的卡）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,3,nil)
	if g:GetCount()>0 then
		-- 显示选出的卡被选为对象的动画
		Duel.HintSelection(g)
		-- 把选出的卡回到卡组并洗切卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
