--超重武者カカ－C
-- 效果：
-- 「超重武者」怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。这张卡不能作为连接素材。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，从手卡丢弃1只怪兽，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
function c33918636.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：可用1只「超重武者」怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x9a),1,1)
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33918636.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己墓地没有魔法·陷阱卡存在的场合，从手卡丢弃1只怪兽，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
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
-- 检查自己墓地是否有魔法·陷阱卡，若没有则满足①/②效果发动或适用的条件。
function c33918636.condition(e)
	-- 统计效果持有者自己墓地中魔法·陷阱卡的数量，并判断其是否为0。
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)==0
end
-- 定义丢弃手卡的代价筛选条件：手卡中的怪兽且可以被丢弃。
function c33918636.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ②效果的发动代价：先检查能否从手卡丢弃1只怪兽，再进行丢弃。
function c33918636.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手牌中存在至少1只可以丢弃的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33918636.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择1只满足条件的手卡怪兽，以代价+丢弃的理由送入墓地。
	Duel.DiscardHand(tp,c33918636.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特召对象的筛选条件：对象是「超重武者」怪兽，并且能以表侧守备表示特殊召唤到指定区域。
function c33918636.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 目标指定处理：计算本卡连接区可用区域；若满足条件则让玩家选择墓地1只「超重武者」怪兽作为对象。
function c33918636.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33918636.spfilter(chkc,e,tp,zone) end
	-- 检查自己场上是否有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可成为对象且能特召到连接区的「超重武者」怪兽。
		and Duel.IsExistingTarget(c33918636.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 显示选择提示消息，告知玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「超重武者」怪兽，并将其登记为本效果的对象。
	local g=Duel.SelectTarget(tp,c33918636.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置操作信息，声明本效果将特殊召唤1只对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：取得对象并确认其仍与效果关联且连接区可用，然后将对象怪兽特殊召唤到本卡的连接区。
function c33918636.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回本效果唯一对象卡（墓地的「超重武者」怪兽）。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽以表侧守备表示特殊召唤到本卡连接区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
	end
end
