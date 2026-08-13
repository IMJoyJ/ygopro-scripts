--セイクリッド・レスカ
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的怪兽表侧守备表示特殊召唤。
function c16906241.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16906241,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c16906241.sptg)
	e2:SetOperation(c16906241.spop)
	c:RegisterEffect(e2)
	c16906241.star_knight_summon_effect=e2
end
-- 过滤函数：判断手卡中的怪兽是否为名字带有「星圣」的怪兽，且能否以表侧守备表示被特殊召唤（同时满足召唤条件和苏生限制）。
function c16906241.filter(c,e,tp)
	return c:IsSetCard(0x53) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标条件：自己主要怪兽区有空位，并且手卡中存在至少1只满足上述过滤条件的「星圣」怪兽。
function c16906241.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查自己主要怪兽区是否有空位（大于0才能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张满足c16906241.filter条件的「星圣」怪兽（exc用于排除不能选择的卡）。
		and Duel.IsExistingMatchingCard(c16906241.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置操作信息：本次效果涉及特殊召唤，预计从手卡特殊召唤1只怪兽（用于其他卡片的连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：确认仍有空位后，让玩家选择1张符合条件的「星圣」怪兽，并将其表侧守备表示特殊召唤。
function c16906241.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查主要怪兽区空位，若无空位则效果处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示消息，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的手卡中选择1张符合c16906241.filter条件的「星圣」怪兽。
	local g=Duel.SelectMatchingCard(tp,c16906241.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上（sumtype为0，表示通过通常效果特殊召唤，并检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
