--早すぎた帰還
-- 效果：
-- ①：把1张手卡除外，以除外的1只自己怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
function c95083785.initial_effect(c)
	-- ①：把1张手卡除外，以除外的1只自己怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c95083785.cost)
	e1:SetTarget(c95083785.target)
	e1:SetOperation(c95083785.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：将手牌中的1张卡作为代价表侧表示除外。
function c95083785.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己手牌中是否存在至少1张可以作为代价除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 给发动玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动玩家从手牌中选择1张可以作为代价除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的手牌作为发动代价表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：筛选除外区中可以里侧守备表示特殊召唤的表侧表示怪兽。
function c95083785.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 发动时的目标选择与合法性检测：检查怪兽区域是否有空位，以及除外区是否有符合条件的自己怪兽，并处理取对象。
function c95083785.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c95083785.filter(chkc,e,tp) end
	-- 在发动阶段（chk==0）检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查除外区是否存在至少1只符合条件的自己怪兽。
		and Duel.IsExistingTarget(c95083785.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给发动玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家选择除外的1只自己怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c95083785.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含将选中的1只怪兽特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理（Activate）：将作为对象的怪兽里侧守备表示特殊召唤，并让对方玩家确认该怪兽。
function c95083785.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若该怪兽仍与效果相关联，则将其里侧守备表示特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 让对方玩家确认被里侧守备表示特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
