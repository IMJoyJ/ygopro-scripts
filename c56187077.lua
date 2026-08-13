--糾罪巧α’－「orgIA」
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：手卡的怪兽的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
-- ③：这张卡反转的场合发动。对方场上1只怪兽破坏。
local s,id,o=GetID()
-- 初始化函数：赋予灵摆属性并允许在灵摆区放置纠罪指示物，注册反转时放置指示物的永续效果、灵摆区检索起动效果（1回合1次）、手卡特殊召唤起动效果、怪兽区对方发动手卡怪兽效果时的检索诱发即时效果、反转时破坏的反转效果，并设置特殊召唤活动计数器
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆卡的发动和灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。（这个卡名的②的灵摆效果1回合只能使用1次）
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
	-- ②：手卡的怪兽的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
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
	-- ③：这张卡反转的场合发动。对方场上1只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- 设置特殊召唤活动计数器：以表侧表示特殊召唤怪兽时计数（用于①效果的发动限制）
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：里侧表示的卡不计数，即只有表侧表示的特殊召唤才被计入
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 反转事件的处理：每次有怪兽反转时，给这张卡放置1个纠罪指示物（0x71）
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆②效果的代价：支付900基本分才能发动
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分作为发动代价
	Duel.PayLPCost(tp,900)
end
-- 检索过滤函数：卡组中可以加入手卡的「纠罪巧」卡（系列0x1d4）
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 灵摆②效果的目标检查：卡组需存在至少3张可加入手卡的「纠罪巧」卡，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：检查卡组中是否存在至少3张满足条件的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆②效果的处理：从卡组选出3张「纠罪巧」卡给对方观看，对方随机选1张加入自己手卡，洗切卡组后剩余的卡回到卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索全部满足条件的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 向自己发送选择提示：请选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 把选出的3张卡给对方观看（确认）
		Duel.ConfirmCards(1-tp,sg)
		-- 向对方发送选择提示：请选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 把对方随机选出的那1张卡以效果原因加入自己手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽①效果的代价检查：手卡的这张卡处于非公开状态（未给对方观看过），且本回合尚未以表侧表示特殊召唤过怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 且本回合以表侧表示特殊召唤怪兽的次数为0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把特殊召唤表示形式限制效果注册给自己玩家，持续到这个回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：特殊召唤的表示形式为表侧表示时被限制（只能以里侧守备表示特殊召唤）
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 特殊召唤过滤函数：手卡中可以以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽①效果的目标检查：不受「神之光」等必须表侧特殊召唤的效果影响、怪兽区有空位且手卡存在可以里侧守备表示特殊召唤的怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 如果自己受到「神圣之光」（EFFECT_DIVINE_LIGHT，不能以里侧守备表示特殊召唤）的影响，则不能发动
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己的怪兽区域是否有可用的空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在至少1只可以以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：预计从手卡把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽①效果的处理：从手卡选1只怪兽以里侧守备表示特殊召唤，洗切手卡；若该怪兽曾是公开状态则给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己的怪兽区域没有空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从手卡选择1只可以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切自己的手卡（隐藏所选怪兽的信息）
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 把选择的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若该怪兽在召唤前处于公开状态，则给对方确认这张卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽②效果的发动条件：对方发动的、发生在手卡的怪兽效果的连锁，且这张卡为里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该连锁效果发生的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_HAND)&loc~=0
		and re:IsActiveType(TYPE_MONSTER) and e:GetHandler():IsFacedown()
end
-- 怪兽②效果的代价：把里侧表示的这张卡变成表侧守备表示才能发动
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把里侧表示的这张卡变成表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 检索过滤函数：卡组中可以加入手卡的「纠罪巧」卡（系列0x1d4）
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 怪兽②效果的目标检查：卡组需存在至少1张可加入手卡的「纠罪巧」卡，并设置加入手卡的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：检查卡组中是否存在至少1张满足条件的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽②效果的处理：从卡组选1张「纠罪巧」卡加入手卡，并给对方确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选择提示：请选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1张满足条件的「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入自己手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 反转③效果的目标检查：无需检查，若对方场上存在怪兽则设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上存在的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：预计破坏对方场上1只怪兽（对象为对方场上的怪兽组）
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 反转③效果的处理：选择对方场上1只怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选择提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己选择对方场上1只怪兽
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选怪兽被选为对象的动画并记录
		Duel.HintSelection(g)
		-- 以效果原因破坏选择的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
