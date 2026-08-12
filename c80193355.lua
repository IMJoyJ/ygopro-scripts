--救出劇
-- 效果：
-- 以场上存在的名称中含有「亚马逊」字样的怪兽为对象的卡发动时这张卡才能发动。将成为对象的怪兽卡弹回持有者手卡，从自己手卡中特殊召唤另1只怪兽上场。
function c80193355.initial_effect(c)
	-- 以场上存在的名称中含有「亚马逊」字样的怪兽为对象的卡发动时这张卡才能发动。将成为对象的怪兽卡弹回持有者手卡，从自己手卡中特殊召唤另1只怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCondition(c80193355.condition)
	e1:SetTarget(c80193355.target)
	e1:SetOperation(c80193355.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的「亚马逊」怪兽
function c80193355.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x4)
end
-- 检查发动的卡的效果是否以场上的「亚马逊」怪兽为对象
function c80193355.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and eg:IsExists(c80193355.cfilter,1,nil)
end
-- 过滤手牌中可以特殊召唤且不包含在被弹回手牌怪兽组中的怪兽
function c80193355.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not g or not g:IsContains(c))
end
-- 效果发动的目标选择与操作信息注册
function c80193355.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在可特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80193355.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	local g=eg:Filter(c80193355.cfilter,nil)
	-- 将成为效果对象的「亚马逊」怪兽设为当前连锁的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息：将成为对象的怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c80193355.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果有关联的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 将成为对象的怪兽弹回持有者手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌选择1只与弹回手牌的怪兽不同的怪兽
	local sg=Duel.SelectMatchingCard(tp,c80193355.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,g)
	-- 将选择的怪兽在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
