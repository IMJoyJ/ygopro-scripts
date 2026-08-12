--ブラッド・オーキス
-- 效果：
-- 这张卡召唤成功时，可以从手卡特殊召唤1只「死亡石斛」。
function c46571052.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡特殊召唤1只「死亡石斛」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46571052,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c46571052.sptg)
	e1:SetOperation(c46571052.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测手牌中是否包含可特殊召唤的「死亡石斛」
function c46571052.filter(c,e,tp)
	return c:IsCode(12965761) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查场上是否有空位且手牌中有符合条件的怪兽
function c46571052.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在满足条件的「死亡石斛」
		and Duel.IsExistingMatchingCard(c46571052.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表明将要特殊召唤一张手牌中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行特殊召唤操作
function c46571052.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认场上是否有空位以进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择符合条件的「死亡石斛」
	local g=Duel.SelectMatchingCard(tp,c46571052.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
