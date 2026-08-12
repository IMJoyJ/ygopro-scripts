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
-- 初始化：为这张卡添加灵摆属性与指示物许可，并依次注册反转放置指示物的永续效果、灵摆②检索效果、手卡①特殊召唤效果、场上②检索效果、反转③无效效果，最后登记特殊召唤行动计数器
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以发动到灵摆区域并用于灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- 这个卡名的②的灵摆效果1回合只能使用1次。②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
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
	-- 注册自定义行动计数器：当自己特殊召唤表侧表示的怪兽（过滤函数返回false的卡）时计数，用于怪兽效果①的发动回合限制
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：里侧表示的卡不计数，即只有特殊召唤表侧表示的怪兽才会使计数器增加
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆效果①的处理：每次有怪兽反转，给灵摆区域的这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆效果②的发动代价函数：检查并支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时检查自己是否能支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分作为这个效果的发动代价
	Duel.PayLPCost(tp,900)
end
-- 过滤函数：筛选可以加入手卡的「纠罪巧」卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 灵摆效果②的目标函数：确认卡组有至少3张「纠罪巧」卡，并设置从卡组把卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时检查自己卡组是否存在至少3张可以加入手卡的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：这个效果将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果②的处理：从卡组选出3张「纠罪巧」卡给对方观看，对方从那之中随机选1张，那1张加入自己手卡，剩余回到卡组并洗切卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己卡组中所有可以加入手卡的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 向自己提示选择要给对方观看的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 把选出的3张「纠罪巧」卡给对方观看
		Duel.ConfirmCards(1-tp,sg)
		-- 向对方提示从那之中随机选择1张
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切卡组，使剩余的卡回到卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 把对方随机选中的那1张卡加入自己手卡（加入手卡时无需再次给对方确认）
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动代价函数：要求这张卡在手卡处于非公开状态（给对方观看才能发动），且本回合自己还未特殊召唤过表侧表示的怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合自己特殊召唤表侧表示怪兽的次数为0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。②：包含把怪兽特殊召唤效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把这个特殊召唤位置限制效果注册给自己，直到回合结束时有效
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：以表侧表示特殊召唤的怪兽被禁止，即这个效果发动的回合自己只能用里侧守备表示特殊召唤怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数：筛选手卡中可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的目标函数：确认自己可以进行里侧守备表示的特殊召唤，并设置从手卡特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若自己受到不能把怪兽里侧表示特殊召唤的效果（如「神圣光辉」）影响，则不能发动
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己的怪兽区域是否有可用的空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1只可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：这个效果将从手卡把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的处理：从手卡选1只怪兽里侧守备表示特殊召唤并洗切手卡；若该怪兽在特殊召唤前处于公开状态，则给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己的怪兽区域没有可用空格，则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只可以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切手卡，隐藏被特殊召唤的卡在手卡中的位置信息
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 把选择的怪兽里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若该怪兽在特殊召唤前处于公开状态，则把里侧守备表示特殊召唤的它给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②的发动条件：对方发动了包含把怪兽特殊召唤效果的卡的效果，且这张卡在怪兽区域里侧表示存在
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and e:GetHandler():IsFacedown()
end
-- 怪兽效果②的发动代价函数：把里侧表示的这张卡变成表侧守备表示作为代价
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把这张卡变成表侧守备表示作为发动代价
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 过滤函数：筛选可以加入手卡的「纠罪巧」卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 怪兽效果②的目标函数：确认卡组有可以加入手卡的「纠罪巧」卡，并设置操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时检查自己卡组是否存在至少1张可以加入手卡的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：这个效果将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②的处理：从卡组选1张「纠罪巧」卡加入手卡，并把加入手卡的卡给对方确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张可以加入手卡的「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡加入自己手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果③的目标函数：检索对方场上可以无效的效果怪兽，并设置无效的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索对方场上所有表侧表示且效果未被无效的效果怪兽
	local g=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：这个效果将把对方场上1只效果怪兽的效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- 怪兽效果③的处理：选对方场上1只效果怪兽，使其效果及其发动的效果直到回合结束时无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己提示选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示且效果未被无效的效果怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 显示该怪兽被选为对象的动画，并记录它被选择
		Duel.HintSelection(g)
		-- 使与该怪兽有关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上1只效果怪兽的效果直到回合结束时无效。（使该怪兽的效果本身无效）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上1只效果怪兽的效果直到回合结束时无效。（使该怪兽发动的效果无效）
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
