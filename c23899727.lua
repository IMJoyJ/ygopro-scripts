--水精鱗－アビスリンデ
-- 效果：
-- 场上的这张卡被破坏送去墓地的场合，可以从卡组把「水精鳞-深渊琳德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊琳德」的效果1回合只能使用1次。
function c23899727.initial_effect(c)
	-- 场上的这张卡被破坏送去墓地的场合，可以从卡组把「水精鳞-深渊琳德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊琳德」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23899727,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,23899727)
	e1:SetCondition(c23899727.condition)
	e1:SetTarget(c23899727.target)
	e1:SetOperation(c23899727.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：这张卡是被破坏并且是从场上被送去墓地，即满足「场上的这张卡被破坏送去墓地的场合」。
function c23899727.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义可特殊召唤的卡的范围：卡名含有「水精鳞」（0x74）、不是「水精鳞-深渊琳德」自身、并且能够被特殊召唤的怪兽。
function c23899727.filter(c,e,tp)
	return c:IsSetCard(0x74) and not c:IsCode(23899727) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的判定：需要自己主要怪兽区有空位，且卡组中存在符合filter条件的怪兽，满足则效果可以发动。
function c23899727.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格；没有空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足filter条件的卡，即卡组中是否有符合条件的「水精鳞」怪兽可特殊召唤。
		and Duel.IsExistingMatchingCard(c23899727.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的处理信息：效果处理时将从卡组特殊召唤1只怪兽，对应「从卡组把……1只名字带有「水精鳞」的怪兽特殊召唤」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：实际执行特殊召唤，先确认仍有可用怪兽区，然后让玩家从卡组选择符合条件的怪兽并正面表示特殊召唤到自己场上。
function c23899727.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位；若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，告知玩家需要从卡组选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中选择1张满足c23899727.filter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c23899727.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
