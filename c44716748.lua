--糾罪巧γ’－「exapatisIA」
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：包含把卡盖放效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
-- ③：这张卡反转的场合发动。对方场上1张魔法·陷阱卡破坏，从手卡把1只怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 卡片初始化函数：注册灵摆属性、指示物系统、灵摆效果①（放置指示物）、灵摆效果②（支付900LP检索）、怪兽效果①（手卡展示特殊召唤）、怪兽效果②（对方盖放效果时检索）、怪兽效果③（反转破坏并特殊召唤），以及设置特殊召唤计数器
function s.initial_effect(c)
	-- 为卡片c添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
	-- ②：包含把卡盖放效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。
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
	-- ③：这张卡反转的场合发动。对方场上1张魔法·陷阱卡破坏，从手卡把1只怪兽里侧守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- 设置自定义活动计数器，用于追踪玩家进行的非里侧表示的特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 定义计数器过滤函数：返回c:IsFacedown()，即只有表侧表示的特殊召唤会被计数（返回false时计数）
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 每次怪兽反转时，给这张卡在灵摆区放置1个纠罪指示物（0x71）
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆效果②的Cost处理：支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付900基本分作为cost
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 让玩家支付900基本分
	Duel.PayLPCost(tp,900)
end
-- 定义检索过滤函数：卡名为「纠罪巧」系列（0x1d4）且可以加入手卡的卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 灵摆效果②的Target处理：检查卡组是否有3张以上「纠罪巧」卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在3张以上满足条件的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果②的Operation处理：从卡组选3张「纠罪巧」卡给对方观看，对方随机选1张加入手卡，剩余洗回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要加入手牌的卡（实际是从卡组选3张）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 给对方玩家确认选中的3张卡
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家选择要加入手牌的卡（随机选择1张）
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切玩家卡组，将剩余的卡返回卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的1张卡加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽效果①的Cost处理：展示手卡的这张卡，并检查本回合是否没有进行过非里侧表示的特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合通过非里侧表示特殊召唤的怪兽数量是否为0（即本回合没有进行过非里侧表示的特殊召唤）
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。②：包含把卡盖放效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡。③：这张卡反转的场合发动。对方场上1张魔法·陷阱卡破坏，从手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将特殊召唤限制效果注册给玩家，使其在本回合内生效
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制过滤函数：禁止表侧表示（POS_FACEUP）的特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 定义特殊召唤过滤函数：可以从手卡里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果①的Target处理：检查是否可以进行里侧守备表示特殊召唤，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受「神圣光辉」等效果影响（这些效果会禁止里侧表示特殊召唤）
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查玩家怪兽区域是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的Operation处理：从手卡选择1只怪兽里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，没有则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只能里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切手卡，重置洗卡检测状态
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中的怪兽以里侧守备表示特殊召唤到玩家场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 如果选中的卡是公开状态（对方已知），则给对方确认特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果②的Condition处理：检查是否是对方发动的包含盖放效果（CATEGORY_MSET或CATEGORY_SSET）的卡的效果，且这张卡是里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():IsFacedown()
		and (re:IsHasCategory(CATEGORY_MSET) or re:IsHasCategory(CATEGORY_SSET))
end
-- 怪兽效果②的Cost处理：将里侧表示的这张卡变成表侧守备表示
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这张卡从里侧表示变成表侧守备表示作为发动cost
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 定义检索过滤函数：卡名为「纠罪巧」系列（0x1d4）且可以加入手卡的卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 怪兽效果②的Target处理：检查卡组是否有「纠罪巧」卡，并设置操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②的Operation处理：从卡组把1张「纠罪巧」卡加入手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果③的Target处理：反转时发动，设置破坏和特殊召唤的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 设置操作信息：破坏对方场上1张魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果③的Operation处理：破坏对方场上1张魔法·陷阱卡，然后从手卡把1只怪兽里侧守备表示特殊召唤
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张魔法·陷阱卡
	local dg=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if dg:GetCount()>0 then
		-- 显示选中为对象的动画效果
		Duel.HintSelection(dg)
		-- 破坏选中的卡，如果破坏成功（返回值不为0）则继续处理特殊召唤
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			-- 检查怪兽区域是否有空位，没有则终止处理
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡选择1只能里侧守备表示特殊召唤的怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 洗切手卡，重置洗卡检测状态
			Duel.ShuffleHand(tp)
			if sg:GetCount()>0 then
				local sc=sg:GetFirst()
				local hint=sc:IsPublic()
				-- 将选中的怪兽以里侧守备表示特殊召唤到玩家场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				if hint then
					-- 如果选中的卡是公开状态，给对方确认特殊召唤的怪兽
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	end
end
