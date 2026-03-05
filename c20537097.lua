--蒼穹の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
-- ②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。把和这张卡相同纵列的对方的卡数量的「苍穹之机界骑士」以外的「机界骑士」怪兽从卡组加入手卡（同名卡最多1张）。
function c20537097.initial_effect(c)
	-- ①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,20537097+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20537097.hspcon)
	e1:SetValue(c20537097.hspval)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。把和这张卡相同纵列的对方的卡数量的「苍穹之机界骑士」以外的「机界骑士」怪兽从卡组加入手卡（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20537097,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,20537098)
	e2:SetTarget(c20537097.thtg)
	e2:SetOperation(c20537097.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c20537097.thcon)
	c:RegisterEffect(e3)
end
-- 用于判断场上是否存在相同纵列的卡。
function c20537097.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 判断特殊召唤时是否满足条件，即是否有足够的召唤区域。
function c20537097.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有存在相同纵列的卡。
	local lg=Duel.GetMatchingGroup(c20537097.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡，计算其可召唤的区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 判断是否有足够的召唤区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置特殊召唤时的召唤区域。
function c20537097.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有存在相同纵列的卡。
	local lg=Duel.GetMatchingGroup(c20537097.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡，计算其可召唤的区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 判断该卡是否从手卡特殊召唤成功。
function c20537097.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 筛选符合条件的「机界骑士」怪兽。
function c20537097.thfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and not c:IsCode(20537097) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息。
function c20537097.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取卡组中符合条件的怪兽。
	local g=Duel.GetMatchingGroup(c20537097.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=c:GetColumnGroup():FilterCount(Card.IsControler,nil,1-tp)
	if c:IsControler(1-tp) then ct=ct+1 end
	if chk==0 then return c:IsRelateToEffect(e) and ct>0 and g:GetClassCount(Card.GetCode)>=ct end
	-- 设置将要处理的卡的数量和位置。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
-- 执行效果处理，将符合条件的怪兽加入手牌。
function c20537097.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取卡组中符合条件的怪兽。
	local g=Duel.GetMatchingGroup(c20537097.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=c:GetColumnGroup():FilterCount(Card.IsControler,nil,1-tp)
	if c:IsControler(1-tp) then ct=ct+1 end
	if ct<=0 or g:GetClassCount(Card.GetCode)<ct then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组。
	local hg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选中的卡加入手牌。
	Duel.SendtoHand(hg,nil,REASON_EFFECT)
	-- 确认对方查看加入手牌的卡。
	Duel.ConfirmCards(1-tp,hg)
end
