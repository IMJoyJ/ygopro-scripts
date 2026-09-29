--セネトナクト・スフィンクス
-- 效果：
-- 「塞尼特」卡降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把「塞尼特纳赫特·斯芬克斯」以外的1张「塞尼特」卡加入手卡。
-- ②：有装备卡装备的这张卡不受对方发动的效果影响。
-- ③：自己·对方回合，把自己场上1张表侧表示的通常怪兽卡送去墓地才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以从自己墓地把1只通常怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册苏生限制、手卡丢弃检索效果、装备状态抗性效果以及二速场上变里侧加特召效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把「塞尼特纳赫特·斯芬克斯」以外的1张「塞尼特」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：有装备卡装备的这张卡不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.eqcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，把自己场上1张表侧表示的通常怪兽卡送去墓地才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以从自己墓地把1只通常怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_MSET+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.poscost)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价：把这张卡从手卡丢弃
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中同名卡以外可以加入手卡的「塞尼特」卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1eb) and c:IsAbleToHand()
end
-- 效果①的目标判定与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组是否存在可加入手卡的「塞尼特」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的操作处理：从卡组把1张「塞尼特」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张同名卡以外的「塞尼特」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的适用条件：自身有装备卡装备
function s.eqcon(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>0
end
-- 抗性过滤：不受对方发动的效果影响
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
-- 过滤场上可作为代价送去墓地的表侧表示通常怪兽卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 效果③的发动代价：把自己场上1张表侧表示的通常怪兽卡送去墓地
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可作为代价送去墓地的表侧表示通常怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示选择要作为代价送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从场上选择1张表侧表示通常怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 作为代价将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤对方场上可以变成里侧守备表示的表侧表示怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果③的目标判定与操作信息设置
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以变成里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以变成里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：改变对方场上怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 过滤墓地中可以特殊召唤的通常怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的操作处理：将对方怪兽全部变为里侧守备表示，随后可选墓地通常怪兽特殊召唤
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上可变成里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的怪兽全部变成里侧守备表示
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0
		-- 检查自己场上是否有空闲怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可特殊召唤的通常怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否从墓地特殊召唤1只通常怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断效果处理，分隔改变表示形式与特殊召唤
		Duel.BreakEffect()
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只通常怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的通常怪兽表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
