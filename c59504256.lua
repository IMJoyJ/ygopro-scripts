--ティスティナの半神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「提斯蒂娜」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「提斯蒂娜」魔法·陷阱卡加入手卡。
-- ②：对方回合，自己场上有「结晶神 提斯蒂娜」存在的场合才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以把对方场上的表侧表示卡全部送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：自己场上有「提斯蒂娜」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「提斯蒂娜」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，自己场上有「结晶神 提斯蒂娜」存在的场合才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以把对方场上的表侧表示卡全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「提斯蒂娜」卡片。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a4)
end
-- 效果①的发动条件函数。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「提斯蒂娜」卡片。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备与合法性检测函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且这张卡可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：卡组中的「提斯蒂娜」魔法·陷阱卡。
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x1a4) and c:IsAbleToHand()
end
-- 效果①的处理函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡从手卡特殊召唤，若特殊召唤失败则结束处理。
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)<1 then return end
	-- 获取卡组中所有满足条件的「提斯蒂娜」魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，询问玩家是否将其加入手卡。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组把1张「提斯蒂娜」魔法·陷阱卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果，使后续的检索处理与特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：自己场上表侧表示的「结晶神 提斯蒂娜」。
function s.gfilter(c)
	return c:IsFaceup() and c:IsCode(86999951)
end
-- 效果②的发动条件函数。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且自己场上是否存在表侧表示的「结晶神 提斯蒂娜」。
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动准备与合法性检测函数。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有可以变成里侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁处理的操作信息：改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
-- 过滤条件：对方场上表侧表示且可以送去墓地的卡。
function s.sfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
-- 效果②的处理函数。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以变成里侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的怪兽全部变成里侧守备表示，若没有怪兽成功改变表示形式则结束处理。
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)<1 then return end
	-- 获取对方场上所有表侧表示且可以送去墓地的卡。
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 若对方场上存在表侧表示的卡，询问玩家是否将其全部送去墓地。
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把对方场上的表侧表示的卡全部送去墓地？"
		-- 中断当前效果，使后续的送去墓地处理与改变表示形式不视为同时进行。
		Duel.BreakEffect()
		-- 将对方场上的表侧表示卡全部送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
