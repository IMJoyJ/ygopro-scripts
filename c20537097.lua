--蒼穹の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
-- ②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。把和这张卡相同纵列的对方的卡数量的「苍穹之机界骑士」以外的「机界骑士」怪兽从卡组加入手卡（同名卡最多1张）。
function c20537097.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,20537097+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20537097.hspcon)
	e1:SetValue(c20537097.hspval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从手卡的召唤·特殊召唤成功的场合才能发动。把和这张卡相同纵列的对方的卡数量的「苍穹之机界骑士」以外的「机界骑士」怪兽从卡组加入手卡（同名卡最多1张）。
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
-- 过滤函数：判断某张卡所在纵列是否存在其他卡（即该纵列卡数量在2张以上），用于筛选出“相同纵列有卡2张以上存在”的相关卡片。
function c20537097.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 特殊召唤规则的条件判定：当询问能否进行规则特殊召唤时返回真；否则计算这张卡的控制者场上可用的主要怪兽区域，要求至少存在一个纵列满足“相同纵列有卡2张以上”，且该纵列对应的自己主要怪兽区有空位。
function c20537097.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有所在纵列有其他卡存在的卡（包含双方场上），用于后续统计哪些纵列满足条件。
	local lg=Duel.GetMatchingGroup(c20537097.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历筛选出的这些卡，逐个计算其所在纵列对应的自己主要怪兽区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 判断计算出的可用主要怪兽区域位集合 zone 中是否存在空位；若存在空位则满足从手卡往那个纵列的自己场上特殊召唤的条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的值函数：返回可特殊召唤到的自己主要怪兽区域位集合（zone），并附带参数0。该返回值用于指定这张卡通过规则特殊召唤时可选择的放置区域。
function c20537097.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有所在纵列有其他卡存在的卡，用于计算可特殊召唤区域。
	local lg=Duel.GetMatchingGroup(c20537097.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡，将每个卡所在纵列对应的自己主要怪兽区域加入 zone 位集合。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 效果②的追加发动条件：判定这张卡在召唤/特殊召唤成功之前是否位于手卡，对应“从手卡的召唤·特殊召唤成功的场合”。
function c20537097.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 检索候选的过滤条件：必须是「机界骑士」怪兽，且不是「苍穹之机界骑士」本身，并能加入手卡。
function c20537097.thfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and not c:IsCode(20537097) and c:IsAbleToHand()
end
-- 效果②的发动条件与目标设定：计算与这张卡相同纵列的对方卡片数量 ct，并检查卡组中满足检索条件的「机界骑士」怪兽的不同卡名数量是否不少于 ct；满足则返回可发动，并设置操作信息。
function c20537097.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取卡组中所有满足检索条件的「机界骑士」怪兽，作为候选卡组。
	local g=Duel.GetMatchingGroup(c20537097.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=c:GetColumnGroup():FilterCount(Card.IsControler,nil,1-tp)
	if c:IsControler(1-tp) then ct=ct+1 end
	if chk==0 then return c:IsRelateToEffect(e) and ct>0 and g:GetClassCount(Card.GetCode)>=ct end
	-- 设置操作信息：本次效果预计将 ct 张卡从卡组加入手卡，供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
-- 效果②的实际处理：确认这张卡仍与效果关联后，计算应检索数量 ct，若卡组中不同卡名数足够，则让玩家选择指定数量的卡名不同的「机界骑士」怪兽加入手卡，并让对方确认。
function c20537097.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取卡组中所有满足检索条件的「机界骑士」怪兽，用于处理时选择。
	local g=Duel.GetMatchingGroup(c20537097.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=c:GetColumnGroup():FilterCount(Card.IsControler,nil,1-tp)
	if c:IsControler(1-tp) then ct=ct+1 end
	if ct<=0 or g:GetClassCount(Card.GetCode)<ct then return end
	-- 向发动玩家显示选择提示：请选择要加入手牌的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选卡组中选出 ct 张卡名互不相同的卡（保证同名卡最多1张），数量精确为 ct。
	local hg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选出的卡片加入其持有者的手卡（效果加入手卡）。
	Duel.SendtoHand(hg,nil,REASON_EFFECT)
	-- 让对手确认加入手卡的卡片。
	Duel.ConfirmCards(1-tp,hg)
end
