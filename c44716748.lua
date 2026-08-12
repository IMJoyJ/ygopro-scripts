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
-- 初始化效果：赋予灵摆属性、允许灵摆区放置纠罪指示物，注册灵摆区的反转放置指示物永续效果、支付900基本分的检索起动效果、手卡的里侧守备特殊召唤起动效果、怪兽区的诱发即时检索效果以及反转时的破坏·特殊召唤效果，并登记特殊召唤计数器
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤与灵摆卡的发动）
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
	-- 注册特殊召唤活动计数器，用于记录本回合玩家特殊召唤表侧表示怪兽的情况
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：表侧表示的卡返回false被计数，里侧表示的特殊召唤不计数
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 灵摆永续效果处理：每次怪兽反转时，给这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 灵摆检索效果的代价：支付900基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认自己可以支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 支付900基本分作为发动代价
	Duel.PayLPCost(tp,900)
end
-- 检索过滤函数：筛选「纠罪巧」系列且可以加入手卡的卡
function s.thfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 灵摆检索效果目标检测：确认卡组有3张以上可加入手卡的「纠罪巧」卡，并声明从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认卡组存在至少3张满足条件的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 声明操作信息：将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆检索效果处理：从卡组选出3张「纠罪巧」卡给对方观看，对方从那之中随机选1张，该卡加入自己手卡，剩余回到卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有满足条件的「纠罪巧」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示自己从「纠罪巧」卡中选择3张要给对方观看的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张卡给对方观看确认
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方从那之中选择1张要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切卡组（剩余的卡回到卡组并打乱顺序）
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选中的1张卡以效果原因加入自己手卡（无需再次确认）
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 手卡特召效果的发动代价检测：手卡的这张卡处于未公开状态，且本回合尚未特殊召唤过表侧表示怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 且本回合进行表侧表示特殊召唤的次数为0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把「本回合自己不用里侧守备表示不能把怪兽特殊召唤」的誓约效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 誓约过滤函数：表侧表示形式的特殊召唤受到限制（即只能以里侧守备表示特殊召唤）
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 特殊召唤过滤函数：检查手卡怪兽是否可以里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 手卡特召效果目标检测：未受神圣光辉类效果影响、主要怪兽区有空位且手卡有可里侧守备表示特殊召唤的怪兽时，声明从手卡特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若自己受到不能以里侧守备表示特殊召唤的效果影响，则不能发动
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 确认自己的主要怪兽区有可用的空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡存在至少1只可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 声明操作信息：将从手卡把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 手卡特召效果处理：自己从手卡选1只怪兽洗切手卡后里侧守备表示特殊召唤，若该卡处于公开状态则给对方观看
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若主要怪兽区没有空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示自己选择1只要特殊召唤的手卡怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只可以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切手卡（隐藏所选卡的位置）
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选择的怪兽里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若特殊召唤的怪兽原本处于公开状态，则给对方观看确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 诱发条件：对方发动包含把卡盖放（怪兽盖放或魔法·陷阱盖放）效果的效果，且这张卡处于里侧表示
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():IsFacedown()
		and (re:IsHasCategory(CATEGORY_MSET) or re:IsHasCategory(CATEGORY_SSET))
end
-- 检索效果的发动代价：把里侧表示的这张卡变成表侧守备表示
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把里侧表示的这张卡变成表侧守备表示作为发动代价
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 检索过滤函数：筛选「纠罪巧」系列且可以加入手卡的卡
function s.thfilter2(c)
	return c:IsSetCard(0x1d4) and c:IsAbleToHand()
end
-- 检索效果目标检测：确认卡组存在可加入手卡的「纠罪巧」卡，并声明从卡组加入手卡的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认卡组存在至少1张满足条件的「纠罪巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 声明操作信息：将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：自己从卡组选1张「纠罪巧」卡加入手卡并给对方观看
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张可以加入手卡的「纠罪巧」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方观看确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 反转效果目标：取得对方场上所有魔法·陷阱卡，若存在则声明破坏1张的操作信息，并声明从手卡特殊召唤的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 声明操作信息：将破坏对方场上1张魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	-- 声明操作信息：将从手卡把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 反转效果处理：自己选对方场上1张魔法·陷阱卡破坏，破坏成功后从手卡把1只怪兽里侧守备表示特殊召唤（公开状态的卡给对方观看）
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为破坏对象
	local dg=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if dg:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画并记录
		Duel.HintSelection(dg)
		-- 以效果原因破坏选中的卡，破坏成功则继续处理特殊召唤
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			-- 破坏成功后，若主要怪兽区没有空格则中断后续特殊召唤处理
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 提示自己选择1只要特殊召唤的手卡怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡选择1只可以里侧守备表示特殊召唤的怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 洗切手卡（隐藏所选卡的位置）
			Duel.ShuffleHand(tp)
			if sg:GetCount()>0 then
				local sc=sg:GetFirst()
				local hint=sc:IsPublic()
				-- 将选择的怪兽里侧守备表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				if hint then
					-- 若特殊召唤的怪兽原本处于公开状态，则给对方观看确认
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	end
end
