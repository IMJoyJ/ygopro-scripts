--D・D・M
-- 效果：
-- 从手卡丢弃1张魔法卡。特殊召唤1只从游戏中除外的持有者为自己的怪兽。这个效果1回合1次，只能在自己的主要阶段发动。
function c82112775.initial_effect(c)
	-- 从手卡丢弃1张魔法卡。特殊召唤1只从游戏中除外的持有者为自己的怪兽。这个效果1回合1次，只能在自己的主要阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82112775,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c82112775.cost)
	e1:SetTarget(c82112775.target)
	e1:SetOperation(c82112775.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中可以丢弃的魔法卡
function c82112775.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 发动代价：从手卡丢弃1张魔法卡
function c82112775.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82112775.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1张魔法卡丢弃
	Duel.DiscardHand(tp,c82112775.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：表侧表示除外的、可以特殊召唤的怪兽
function c82112775.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测
function c82112775.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c82112775.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只可以特殊召唤的、持有者为自己的怪兽
		and Duel.IsExistingTarget(c82112775.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只除外区的、持有者为自己的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82112775.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤选中的除外怪兽
function c82112775.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
