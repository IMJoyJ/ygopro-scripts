--ハンマー・シャーク
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。这张卡的等级下降1星，从手卡把1只水属性·3星以下的怪兽特殊召唤。
function c17201174.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17201174,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c17201174.sptg)
	e1:SetOperation(c17201174.spop)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤对象的筛选条件：水属性·3星以下且可以特殊召唤的手牌怪兽。
function c17201174.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前的合法性检查：确认自身等级、空位、手牌对象均满足条件。
function c17201174.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身等级不低于2（以保证下降1星后仍合法）且我方主要怪兽区有空位。
	if chk==0 then return e:GetHandler():IsLevelAbove(2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足过滤条件（水属性·3星以下且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c17201174.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：声明将从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：确认此卡仍表侧且与效果关联，令其等级下降1星；再从手卡把1只水属性·3星以下的怪兽特殊召唤。
function c17201174.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 处理时若我方主要怪兽区没有空位，则不能特殊召唤，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌选择1张满足条件（水属性·3星以下且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c17201174.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到我方怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
