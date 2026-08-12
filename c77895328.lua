--暗黒界の門番 ゼンタ
-- 效果：
-- 自己对「暗黑界的门番 真塔」1回合只能有1次特殊召唤。
-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「暗黑界之门」加入手卡。
-- ②：这张卡被除外的场合，若自己场上有「暗黑界」卡存在则能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数，设置同名卡1回合只能特殊召唤1次，并注册①和②效果
function s.initial_effect(c)
	-- 注册该卡片记载了「暗黑界之门」（卡号33017655）的卡片密码
	aux.AddCodeList(c,33017655)
	c:SetSPSummonOnce(id)
	-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「暗黑界之门」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，若自己场上有「暗黑界」卡存在则能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价函数，检查并执行将自身从手卡丢弃去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将自身作为发动代价丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中卡名为「暗黑界之门」且能加入手卡的卡
function s.filter(c)
	return c:IsCode(33017655) and c:IsAbleToHand()
end
-- ①效果的发动目标函数，检查卡组中是否存在「暗黑界之门」并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果的处理是将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理函数，从卡组将1张「暗黑界之门」加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中第一张满足过滤条件的卡
	local tc=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将目标卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤自己场上表侧表示的「暗黑界」卡片
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6)
end
-- ②效果的发动条件函数，检查自己场上是否存在「暗黑界」卡片
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「暗黑界」卡片
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的发动目标函数，检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示此效果的处理是将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的效果处理函数，若自身仍符合条件，则将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
