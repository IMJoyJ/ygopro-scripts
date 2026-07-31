--糾罪巧ϝ’－「tromarIA」
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：包含把怪兽特殊召唤效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
-- ③：这张卡反转的场合发动。对方场上1只效果怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片的灵摆属性和效果，包括灵摆区指示物、灵摆效果、怪兽效果的注册
function s.initial_effect(c)
	-- 为卡片启用灵摆属性，使其可以在灵摆区存在并能够进行灵摆召唤
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
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：包含把怪兽特殊召唤效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
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
	-- ③：这张卡反转的场合发动。对方场上1只效果怪兽的效果直到回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
	-- 设置自定义活动计数器，用于限制自己回合的特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：只计算里侧表示的怪兽的特殊召唤
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 反转时触发效果：给灵摆区的这张卡放置1个纠罪指示物(0x71)
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆效果②的成本：支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付900点LP
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 执行支付900点LP的操作
	Duel.PayLPCost(tp,900)
end
-- 检索过滤函数：筛选「纠罪巧」系列卡片且能被加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 灵摆效果②的目标：检查卡组是否有至少3张满足条件的「纠罪巧」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少3张可加入手牌的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：目标是将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果②的处理：从卡组选择3张「纠罪巧」给对方观看，对方随机选1张加入手卡，其余回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足「纠罪巧」检索条件的卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 让对方确认选出的3张卡
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选中的卡加入自己手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽效果①的成本：手卡公开且本回合未进行过特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查自己本回合是否已经进行过特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册一个限制特殊召唤的效果：自己回合只能特殊召唤里侧守备表示的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将特殊召唤限制效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：只能特殊召唤里侧守备表示的怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 特殊召唤过滤函数：筛选可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的目标：检查是否有可用的怪兽区域和满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受神圣光影响（部分卡片效果限制）
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查玩家是否有可用的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否有可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：目标特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的处理：特殊召唤手卡中的1只怪兽里侧守备表示
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家没有可用的怪兽区域则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 特殊召唤选中的怪兽为里侧守备表示
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 如果怪兽是公开的，则让对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②的触发条件：对方发动包含特殊召唤效果的处理时，且这张卡为里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and e:GetHandler():IsFacedown()
end
-- 怪兽效果②的成本：将这张卡变成表侧守备表示
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这张卡变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 检索过滤函数：筛选「纠罪巧」系列卡片且能被加入手卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 怪兽效果②的目标：检查卡组是否有满足条件的「纠罪巧」卡
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：目标是将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②的处理：从卡组检索1张「纠罪巧」卡加入手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入自己手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果③的目标：准备无效对方场上1只效果怪兽
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示的效果怪兽
	local g=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：目标无效1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- 怪兽效果③的处理：选择对方1只效果怪兽并使其效果无效直到回合结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只效果怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 显示被选中的卡
		Duel.HintSelection(g)
		-- 使与该卡相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ③：这张卡反转的场合发动。对方场上1只效果怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ③：这张卡反转的场合发动。对方场上1只效果怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
