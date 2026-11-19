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
	c:RegisterEffect(e1)
end
-- 发动条件检查函数：判断这张卡是否从场上因破坏而送去墓地
function c71341529.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动代价函数：检查玩家能否丢弃2张手卡，并在发动时选择2张手卡丢弃作为代价
function c71341529.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己手卡中（排除自身）至少有2张可以作为代价丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 让玩家选择2张手卡作为发动代价丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 发动检查与操作信息设置函数：确认场上存在怪兽区空位且墓地的这张卡可被特殊召唤
function c71341529.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记操作信息：将会把墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若墓地的这张卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上
function c71341529.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
