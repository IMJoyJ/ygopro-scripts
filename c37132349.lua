--おジャマ・レッド
-- 效果：
-- 这张卡召唤成功时，可以从手卡把名字带有「扰乱」的怪兽最多4只在自己场上攻击表示特殊召唤。
function c37132349.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把名字带有「扰乱」的怪兽最多4只在自己场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37132349,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c37132349.target)
	e1:SetOperation(c37132349.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测手牌中是否包含名字带有「扰乱」且可以特殊召唤的怪兽。
function c37132349.filter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果的发动时点处理函数，判断是否满足发动条件。
function c37132349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手牌中是否存在至少一张名字带有「扰乱」的怪兽。
		and Duel.IsExistingMatchingCard(c37132349.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将要从手牌中特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，负责执行特殊召唤操作。
function c37132349.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送提示信息，提示其选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据过滤条件从玩家手牌中选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c37132349.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以攻击表示特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
