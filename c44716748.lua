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
-- 卡片效果初始化入口函数，定义所有灵摆和怪兽效果
function s.initial_effect(c)
	-- 为卡片启用灵摆属性，允许灵摆召唤和灵摆卡发动
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- ②：支付900基本分才能发动。从卡组把3张「纠罪巧」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组
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
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：包含把卡盖放效果的卡的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。从卡组把1张「纠罪巧」卡加入手卡
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
	-- ③：这张卡反转的场合发动。对方场上1张魔法·陷阱卡破坏，从手卡把1只怪兽里侧守备表示特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- 设置计数器限制自己回合的特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数，返回false表示对里侧表示的卡计数
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 放置纠罪指示物的操作，每次怪兽反转时触发
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆效果2的cost：支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付900LP
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 实际支付900LP
	Duel.PayLPCost(tp,900)
end
-- 定义检索过滤器，筛选「纠罪巧」系列且能加入手牌的卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 设置检索目标，检查卡组是否有至少3张符合条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少3张可检索的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息，目标是将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，选择3张卡给对方观看并让对方随机选1张
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示自己选择要展示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 让对手确认选中的3张卡
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对手随机选择1张卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选中的卡加入自己手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 怪兽效果1的cost：手卡公开且该回合未进行过特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查该回合特殊召唤次数是否为0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册限制特殊召唤的效果，规定该回合不能表侧表示特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能表侧表示特殊召唤的过滤函数
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 定义可以特殊召唤的怪兽过滤器，要求怪兽能以里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置特殊召唤目标，检查是否有空位和符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受神圣光效果影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己主要怪兽区是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否有可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，目标是将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己没有空位则结束
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只怪兽特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中的怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 如果怪兽是公开的则让对手确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果2的触发条件：对方发动盖放卡的效果且自己里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():IsFacedown()
		and (re:IsHasCategory(CATEGORY_MSET) or re:IsHasCategory(CATEGORY_SSET))
end
-- 怪兽效果2的cost：将里侧表示的这张卡变成表侧守备表示
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这张卡变成表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 定义检索过滤器，筛选「纠罪巧」系列且能加入手牌的卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 设置检索目标，检查卡组是否有符合条件的卡
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可检索的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，目标是将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入自己手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置反转破坏效果的目标
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有魔法陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 设置操作信息，目标破坏1张魔法陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	-- 设置操作信息，目标特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行反转破坏效果：破坏魔法陷阱卡并特殊召唤怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择要破坏的魔法陷阱卡
	local dg=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if dg:GetCount()>0 then
		-- 显示被选中的魔法陷阱卡
		Duel.HintSelection(dg)
		-- 如果破坏成功则继续执行特殊召唤
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			-- 检查是否有空位进行特殊召唤
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 提示选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家选择要特殊召唤的怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 洗切手卡
			Duel.ShuffleHand(tp)
			if sg:GetCount()>0 then
				local sc=sg:GetFirst()
				local hint=sc:IsPublic()
				-- 将选中的怪兽以里侧守备表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				if hint then
					-- 如果怪兽是公开的则让对手确认
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	end
end
