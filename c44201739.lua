--ミラァと燐寸之仔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。同名卡在对方墓地存在的3张卡从手卡·卡组给对方观看（同名卡最多1张），这张卡特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡的①的效果特殊召唤的这张卡送去墓地才能发动。把1张对方发动的那张卡的同名卡从卡组·额外卡组送去墓地，那个发动无效。
function c44201739.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。同名卡在对方墓地存在的3张卡从手卡·卡组给对方观看（同名卡最多1张），这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44201739,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,44201739)
	e1:SetTarget(c44201739.sptg)
	e1:SetOperation(c44201739.spop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡的①的效果特殊召唤的这张卡送去墓地才能发动。把1张对方发动的那张卡的同名卡从卡组·额外卡组送去墓地，那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44201739,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44201739+1)
	e2:SetCondition(c44201739.negcon)
	e2:SetCost(c44201739.negcost)
	e2:SetTarget(c44201739.negtg)
	e2:SetOperation(c44201739.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查手卡或卡组中是否存在与指定卡同名且未公开的卡
function c44201739.cfilter(c,tp)
	-- 检查以玩家tp来看，对方墓地是否存在至少1张与c卡同名的卡，并且c卡未公开
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,0,LOCATION_GRAVE,1,nil,c:GetCode()) and not c:IsPublic()
end
-- 特殊召唤效果的发动条件判断函数，检查是否满足特殊召唤的条件
function c44201739.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足cfilter条件的卡组，用于判断是否可以发动特殊召唤效果
	local g=Duel.GetMatchingGroup(c44201739.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
	-- 检查是否满足特殊召唤的条件，包括卡组中存在3张不同名的同名卡、场上存在空位、自身可以被特殊召唤
	if chk==0 then return g:CheckSubGroup(aux.dncheck,3,3) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的发动处理函数，执行特殊召唤操作
function c44201739.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足cfilter条件的卡组，用于判断是否可以发动特殊召唤效果
	local g=Duel.GetMatchingGroup(c44201739.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
	-- 检查是否满足特殊召唤的条件，包括卡组中存在3张不同名的同名卡
	if g:CheckSubGroup(aux.dncheck,3,3) then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从满足条件的卡组中选择3张不同名的卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3,nil)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		if not c:IsRelateToEffect(e) then return end
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 无效效果发动的条件判断函数，检查是否满足无效效果发动的条件
function c44201739.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身未在战斗中被破坏、发动者不是自己、且该连锁可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
-- 无效效果发动的费用支付函数，将自身送去墓地作为费用
function c44201739.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为无效效果发动的费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于查找与指定效果同名且可以送去墓地的卡
function c44201739.filter(c,re)
	return c:IsCode(re:GetHandler():GetCode()) and c:IsAbleToGrave()
end
-- 无效效果发动的目标设定函数，检查是否可以找到目标卡并设置操作信息
function c44201739.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足无效效果发动的条件，包括卡组或额外卡组中存在至少1张同名卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44201739.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,re) end
	-- 设置无效效果发动的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置将卡送去墓地的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 无效效果发动的处理函数，执行无效效果并送去墓地
function c44201739.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组或额外卡组中选择1张同名卡
	local g=Duel.SelectMatchingCard(tp,c44201739.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,re)
	-- 检查是否成功将卡送去墓地并确认其在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 使指定连锁发动无效
		Duel.NegateActivation(ev)
	end
end
