--星痕の機界騎士
-- 效果：
-- 「机界骑士」怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：和这张卡相同纵列没有其他卡存在的场合，这张卡可以直接攻击。
-- ②：额外怪兽区域的这张卡的所连接区没有怪兽存在的场合，这张卡不会被效果破坏，不会成为对方的效果的对象。
-- ③：把和这张卡相同纵列1张其他的自己的卡送去墓地才能发动。从卡组把1只「机界骑士」怪兽守备表示特殊召唤。
function c38502358.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2张属于「机界骑士」的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x10c),2)
	-- 和这张卡相同纵列没有其他卡存在的场合，这张卡可以直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c38502358.dircon)
	c:RegisterEffect(e1)
	-- 额外怪兽区域的这张卡的所连接区没有怪兽存在的场合，这张卡不会被效果破坏，不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c38502358.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为tgoval函数，使该效果不会成为对方的卡的效果对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：把和这张卡相同纵列1张其他的自己的卡送去墓地才能发动。从卡组把1只「机界骑士」怪兽守备表示特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38502358,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,38502358)
	e4:SetCost(c38502358.spcost)
	e4:SetTarget(c38502358.sptg)
	e4:SetOperation(c38502358.spop)
	c:RegisterEffect(e4)
end
-- 判断当前怪兽是否处于纵列中没有其他卡存在的状态
function c38502358.dircon(e)
	return e:GetHandler():GetColumnGroupCount()==0
end
-- 判断当前怪兽是否在额外怪兽区域且其连接区没有怪兽存在
function c38502358.indcon(e)
	local c=e:GetHandler()
	return c:GetSequence()>4 and c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- 筛选满足条件的卡：在指定纵列中、可以作为墓地代价、且目标玩家场上存在空位
function c38502358.spcfilter(c,g,tp)
	-- 判断卡是否在指定纵列中、是否可以送去墓地作为代价、且目标玩家场上存在空位
	return g:IsContains(c) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选满足条件的卡：属于「机界骑士」且可以守备表示特殊召唤
function c38502358.spfilter(c,e,tp)
	return c:IsSetCard(0x10c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理效果发动的费用：选择一张在相同纵列中的卡送去墓地
function c38502358.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	-- 检查是否有满足条件的卡可以作为墓地代价
	if chk==0 then return Duel.IsExistingMatchingCard(c38502358.spcfilter,tp,LOCATION_ONFIELD,0,1,c,cg,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并将其送去墓地
	local g=Duel.SelectMatchingCard(tp,c38502358.spcfilter,tp,LOCATION_ONFIELD,0,1,1,c,cg,tp)
	-- 将选中的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的发动目标：从卡组中选择一只「机界骑士」怪兽进行特殊召唤
function c38502358.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「机界骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38502358.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：从卡组选择一只「机界骑士」怪兽守备表示特殊召唤
function c38502358.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查目标玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只满足条件的「机界骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c38502358.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
