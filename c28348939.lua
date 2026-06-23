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
-- 过滤函数，用于判断手卡中是否存在满足条件的怪兽（4星以下、通常怪兽、可特殊召唤）
function c28348939.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断函数，检查是否满足特殊召唤的条件
function c28348939.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c28348939.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c28348939.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c28348939.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
