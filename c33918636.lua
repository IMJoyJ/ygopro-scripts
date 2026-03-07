--超重武者カカ－C
-- 效果：
-- 「超重武者」怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。这张卡不能作为连接素材。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，从手卡丢弃1只怪兽，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
function c33918636.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，使用1张满足「超重武者」属性的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x9a),1,1)
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己墓地没有魔法·陷阱卡存在的场合，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33918636.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 自己墓地没有魔法·陷阱卡存在的场合，从手卡丢弃1只怪兽，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33918636,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,33918636)
	e3:SetCondition(c33918636.condition)
	e3:SetCost(c33918636.spcost)
	e3:SetTarget(c33918636.sptg)
	e3:SetOperation(c33918636.spop)
	c:RegisterEffect(e3)
end
-- 判断自己墓地是否没有魔法·陷阱卡
function c33918636.condition(e)
	-- 返回自己墓地魔法·陷阱卡的数量是否为0
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)==0
end
-- 过滤手卡中可以丢弃的怪兽
function c33918636.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 支付效果代价，丢弃1只手卡中的怪兽
function c33918636.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33918636.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1只满足条件的怪兽
	Duel.DiscardHand(tp,c33918636.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤墓地中的「超重武者」怪兽，检查是否可以特殊召唤
function c33918636.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 设置效果目标，选择墓地中的「超重武者」怪兽作为特殊召唤对象
function c33918636.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33918636.spfilter(chkc,e,tp,zone) end
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c33918636.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c33918636.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置效果操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c33918636.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
	end
end
