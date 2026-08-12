--水精鱗－アビスグンデ
-- 效果：
-- 这张卡从手卡丢弃去墓地的场合，可以从自己墓地选择「水精鳞-深渊昆德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊昆德」的效果1回合只能使用1次。
function c69293721.initial_effect(c)
	-- 这张卡从手卡丢弃去墓地的场合，可以从自己墓地选择「水精鳞-深渊昆德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊昆德」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69293721,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,69293721)
	e1:SetCondition(c69293721.condition)
	e1:SetTarget(c69293721.target)
	e1:SetOperation(c69293721.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：此卡从手卡被丢弃送去墓地。
function c69293721.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DISCARD) and e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤条件：自己墓地中「水精鳞-深渊昆德」以外的名字带有「水精鳞」且可以特殊召唤的怪兽。
function c69293721.filter(c,e,tp)
	return c:IsSetCard(0x74) and not c:IsCode(69293721) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检查。
function c69293721.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69293721.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽作为效果对象。
		and Duel.IsExistingTarget(c69293721.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足过滤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c69293721.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽特殊召唤。
function c69293721.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
