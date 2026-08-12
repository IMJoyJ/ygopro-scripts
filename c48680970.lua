--永遠の魂
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地把1只「黑魔术师」特殊召唤。
-- ●从卡组把1张「黑·魔·导」或「千把刀」加入手卡。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的怪兽区域的「黑魔术师」不受对方的效果影响。
-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的怪兽全部破坏。
function c48680970.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与「黑魔术师」的关联
	aux.AddCodeList(c,46986414)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。●从自己的手卡·墓地把1只「黑魔术师」特殊召唤。●从卡组把1张「黑·魔·导」或「千把刀」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,48680970)
	e2:SetTarget(c48680970.target)
	e2:SetOperation(c48680970.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己的怪兽区域的「黑魔术师」不受对方的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c48680970.etarget)
	e3:SetValue(c48680970.efilter)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c48680970.descon)
	e4:SetTarget(c48680970.destg)
	e4:SetOperation(c48680970.desop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断手牌或墓地中的「黑魔术师」是否可以被特殊召唤
function c48680970.filter1(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于判断卡组中的「黑·魔·导」或「千把刀」是否可以加入手牌
function c48680970.filter2(c)
	return c:IsCode(2314238,63391643) and c:IsAbleToHand()
end
-- 效果处理函数，判断是否满足发动条件并选择发动效果
function c48680970.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌或墓地是否存在满足条件的「黑魔术师」
		and Duel.IsExistingMatchingCard(c48680970.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查玩家卡组是否存在满足条件的「黑·魔·导」或「千把刀」
	local b2=Duel.IsExistingMatchingCard(c48680970.filter2,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择发动效果1：从自己的手卡·墓地把1只「黑魔术师」特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(48680970,1),aux.Stringid(48680970,2))  --"「黑魔术师」特殊召唤/「黑·魔·导」或者「千把刀」加入手卡"
	elseif b1 then
		-- 选择发动效果1：从自己的手卡·墓地把1只「黑魔术师」特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(48680970,1))  --"「黑魔术师」特殊召唤"
	else
		-- 选择发动效果2：从卡组把1张「黑·魔·导」或「千把刀」加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(48680970,2))+1  --"「黑·魔·导」或者「千把刀」加入手卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息，标记将要特殊召唤的卡牌来源为手牌或墓地
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息，标记将要加入手牌的卡牌来源为卡组
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果执行函数，根据选择的效果类型执行相应的处理
function c48680970.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的「黑魔术师」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌或墓地选择满足条件的「黑魔术师」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48680970.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「黑魔术师」特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要加入手牌的「黑·魔·导」或「千把刀」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择满足条件的「黑·魔·导」或「千把刀」
		local g=Duel.SelectMatchingCard(tp,c48680970.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡牌加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡牌
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果目标过滤函数，筛选出场上的「黑魔术师」
function c48680970.etarget(e,c)
	return c:IsCode(46986414)
end
-- 效果过滤函数，判断是否对对方的效果免疫
function c48680970.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 破坏效果发动条件，判断该卡是否以表侧表示离开场上的
function c48680970.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 破坏效果处理函数，设置要破坏的卡牌为场上所有怪兽
function c48680970.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有怪兽作为将被破坏的目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息，标记将要破坏的卡牌数量为场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果执行函数，对场上所有怪兽进行破坏处理
function c48680970.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有怪兽作为将被破坏的目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 对场上所有怪兽进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
