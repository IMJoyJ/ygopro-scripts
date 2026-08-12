--首領亀
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以从自己的手卡特殊召唤任意数量的「首领龟」上场。
function c3493978.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，可以从自己的手卡特殊召唤任意数量的「首领龟」上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3493978,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c3493978.target)
	e1:SetOperation(c3493978.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测手牌中是否包含可特殊召唤的「首领龟」
function c3493978.filter(c,e,tp)
	return c:IsCode(3493978) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的target函数，判断是否满足发动条件
function c3493978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手牌中是否存在至少一张「首领龟」
		and Duel.IsExistingMatchingCard(c3493978.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡牌数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的operation函数，执行特殊召唤操作
function c3493978.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择满足条件的「首领龟」
	local g=Duel.SelectMatchingCard(tp,c3493978.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「首领龟」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
