--素早いマンタ
-- 效果：
-- 场上存在的这张卡被卡的效果送去墓地时，可以从自己卡组把「迅捷蝠鲼」任意数量特殊召唤。
function c46384403.initial_effect(c)
	-- 场上存在的这张卡被卡的效果送去墓地时，可以从自己卡组把「迅捷蝠鲼」任意数量特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46384403,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46384403.condition)
	e1:SetTarget(c46384403.target)
	e1:SetOperation(c46384403.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡从场上被卡的效果送去墓地时才满足发动条件。
function c46384403.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 发动时进行合法性检查并设置特殊召唤的处理信息：若卡组存在符合条件的「迅捷蝠鲼」则可发动，并在发动时宣言将进行特殊召唤。
function c46384403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张能够被本次效果特殊召唤的「迅捷蝠鲼」。
	if chk==0 then return Duel.IsExistingMatchingCard(c46384403.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理时预计要从卡组特殊召唤1张「迅捷蝠鲼」的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤的筛选条件：必须是卡名「迅捷蝠鲼」，且可以被当前效果特殊召唤。
function c46384403.filter(c,e,tp)
	return c:IsCode(46384403) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：根据可用怪兽区数量选择最多相应数量的「迅捷蝠鲼」从卡组特殊召唤；若场上适用「青眼精灵龙」的效果，则最多只能特殊召唤1只。
function c46384403.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示发动玩家选择要特殊召唤的「迅捷蝠鲼」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只到可用怪兽区数量（受「青眼精灵龙」限制时为1只）的「迅捷蝠鲼」。
	local g=Duel.SelectMatchingCard(tp,c46384403.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「迅捷蝠鲼」以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
