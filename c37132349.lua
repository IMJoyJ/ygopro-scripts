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
-- 筛选手卡中满足名字带有「扰乱」字段、并且能够被当前效果以表侧攻击表示特殊召唤的怪兽。
function c37132349.filter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动的时机检测：自己主要怪兽区存在可用空格，且手卡中至少有1张满足「扰乱」特殊召唤条件的怪兽。
function c37132349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为效果发动条件，检查自己场上是否还有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡中是否存在至少1张名字带有「扰乱」且能被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c37132349.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：明确该效果涉及特殊召唤，预计处理1张手卡的怪兽，具体数量在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：根据可用怪兽区空格数确定最多可特殊召唤的数量（通常最多4只，若受“青眼精灵龙”效果影响则最多1只），由玩家从手卡选择1只至上限数量的「扰乱」怪兽，以表侧攻击表示特殊召唤。
function c37132349.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的主要怪兽区空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，供玩家从手卡中挑选要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡中选择1只到ft只满足条件的「扰乱」怪兽，该选择不取对象。
	local g=Duel.SelectMatchingCard(tp,c37132349.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将被选择的「扰乱」怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
