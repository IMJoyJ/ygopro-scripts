--白虎の召喚士
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的通常怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升100。
function c28348939.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28348939,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28348939.sptg)
	e1:SetOperation(c28348939.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(100)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选满足条件的卡——等级4以下、通常怪兽，且能够被当前效果特殊召唤。
function c28348939.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：己方怪兽区有空位，且手牌存在至少1只符合条件的通常怪兽时，允许发动。
function c28348939.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区域是否存在至少1个可用空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足过滤条件的卡（4星以下通常怪兽且可被特殊召唤）。
		and Duel.IsExistingMatchingCard(c28348939.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：标记本次效果为特殊召唤分类，预定从手牌特殊召唤1只怪兽（具体对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若怪兽区仍有空位，则选择手牌中1只符合条件的通常怪兽，以表侧表示特殊召唤到己方场上。
function c28348939.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方怪兽区没有可用空格，则效果处理中止，无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向选择玩家显示提示消息：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足过滤条件的卡（4星以下通常怪兽且可被特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c28348939.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的手牌怪兽以表侧表示特殊召唤到己方场上（正常检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
