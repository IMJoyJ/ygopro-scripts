--電気海月－フィサリア－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组以及自己场上的表侧表示的卡之中把1张「海」送去墓地才能发动。从手卡把1只水属性怪兽特殊召唤。
-- ②：场上有「海」存在，对方把魔法·怪兽的效果发动时才能发动。那个效果无效。那之后，可以让这张卡的攻击力·守备力上升600。
function c95824983.initial_effect(c)
	-- 注册该卡片记有卡名「海」的事实
	aux.AddCodeList(c,22702055)
	-- ①：从手卡·卡组以及自己场上的表侧表示的卡之中把1张「海」送去墓地才能发动。从手卡把1只水属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95824983,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,95824983)
	e1:SetCost(c95824983.spcost)
	e1:SetTarget(c95824983.sptg)
	e1:SetOperation(c95824983.spop)
	c:RegisterEffect(e1)
	-- ②：场上有「海」存在，对方把魔法·怪兽的效果发动时才能发动。那个效果无效。那之后，可以让这张卡的攻击力·守备力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95824983,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,95824984)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c95824983.discon)
	e2:SetTarget(c95824983.distg)
	e2:SetOperation(c95824983.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡、卡组或场上表侧表示的「海」
function c95824983.cfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and (not c:IsOnField() or c:IsFaceup())
end
-- 效果①的发动代价（Cost）处理
function c95824983.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡、卡组、场上是否存在可以送去墓地的「海」
	if chk==0 then return Duel.IsExistingMatchingCard(c95824983.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡、卡组或场上表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,c95824983.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：手卡中可以特殊召唤的水属性怪兽
function c95824983.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）处理
function c95824983.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在可以特殊召唤的水属性怪兽
		and Duel.IsExistingMatchingCard(c95824983.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（Operation）
function c95824983.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c95824983.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件（Condition）过滤
function c95824983.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「海」
	return Duel.IsEnvironment(22702055)
		-- 并且对方发动了魔法或怪兽的效果，且该效果可以被无效
		and ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果②的发动准备（Target）处理
function c95824983.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果②的效果处理（Operation）
function c95824983.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若成功使效果无效，且此卡仍在场上表侧表示存在
	if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and c:IsFaceup()
		-- 询问玩家是否选择让这张卡的攻击力·守备力上升600
		and Duel.SelectYesNo(tp,aux.Stringid(95824983,2)) then  --"是否上升攻击力·守备力？"
		-- 中断当前效果处理，使后续的攻防上升处理不与无效效果同时进行
		Duel.BreakEffect()
		-- 可以让这张卡的攻击力·守备力上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
