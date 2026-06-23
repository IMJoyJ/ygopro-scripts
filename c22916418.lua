--超人伝－マントマン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：原本持有者是自己的表侧表示卡在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，不能解放，不会被战斗破坏。
-- ③：这张卡召唤·特殊召唤的回合的结束阶段才能发动。这张卡回到卡组最下面。那之后，可以让原本持有者是自己的场上1张表侧表示卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册多个永续效果和起动效果
function s.initial_effect(c)
	-- 这张卡只要在怪兽区域存在，不能解放
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- 这张卡只要在怪兽区域存在，不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 原本持有者是自己的表侧表示卡在对方场上存在的场合才能发动。这张卡从手卡特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	-- 这张卡召唤·特殊召唤的回合的结束阶段才能发动。这张卡回到卡组最下面。那之后，可以让原本持有者是自己的场上1张表侧表示卡回到手卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCondition(s.retcon)
	e5:SetTarget(s.rettg)
	e5:SetOperation(s.retop)
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		-- 注册全局效果，用于记录召唤和特殊召唤的卡片
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的处理函数为aux.sumreg，用于记录召唤和特殊召唤的卡片
		ge1:SetOperation(aux.sumreg)
		-- 将全局效果ge1注册给玩家0（场上的所有卡片）
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将全局效果ge2注册给玩家0（场上的所有卡片）
		Duel.RegisterEffect(ge2,0)
	end
end
-- 定义过滤函数，用于筛选自己控制且表侧表示的卡
function s.cfilter(c,tp)
	return c:GetOwner()==tp and c:IsFaceup()
end
-- 判断是否满足特殊召唤的条件，即对方场上存在自己控制的表侧表示卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在自己控制的表侧表示卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_ONFIELD,1,nil,tp)
end
-- 设置特殊召唤效果的目标处理函数，检查是否有足够的召唤位置和召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤效果的处理函数，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义结束阶段效果的触发条件，判断该卡是否在召唤或特殊召唤的回合
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 定义过滤函数，用于筛选自己控制且表侧表示并能送入手牌的卡
function s.thfilter(c,tp)
	return c:GetOwner()==tp and c:IsFaceup() and c:IsAbleToHand()
end
-- 设置结束阶段效果的目标处理函数，检查该卡是否能送入卡组
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息，表示将要将该卡送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 定义结束阶段效果的处理函数，执行将卡送回卡组并可选择送回手牌的操作
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否能送入卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 检查对方场上是否存在自己控制且表侧表示的卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		-- 询问玩家是否选择将卡送回手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选卡回到手卡？"
		-- 中断当前效果处理，使之后的效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要送回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择满足条件的卡
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
		if #sg>0 then
			-- 显示选卡动画效果
			Duel.HintSelection(sg)
			-- 将选中的卡送回手牌
			Duel.SendtoHand(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
