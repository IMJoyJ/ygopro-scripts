--インフェルニティ・ナイト
-- 效果：
-- 场上存在的这张卡被破坏送去墓地时，可以丢弃2张手卡把这张卡从墓地特殊召唤。
function c71341529.initial_effect(c)
	-- 场上存在的这张卡被破坏送去墓地时，可以丢弃2张手卡把这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71341529,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c71341529.spcon)
	e1:SetCost(c71341529.spcost)
	e1:SetTarget(c71341529.sptg)
	e1:SetOperation(c71341529.spop)
	e1:SetValue(c71341529.valcheck)
	c:RegisterEffect(e1)
end
-- 检查此卡是否在场上被破坏并送去墓地
function c71341529.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 丢弃2张手卡作为效果发动的代价
function c71341529.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身外至少2张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 玩家选择并丢弃2张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 检查怪兽区域是否有空位以及此卡是否可以特殊召唤
function c71341529.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 若此卡仍存在于墓地，则将其特殊召唤
function c71341529.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
