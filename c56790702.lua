--異次元の強襲艦
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：除外的自己的卡是3张的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击宣言之际，自己必须从自己墓地把1张卡除外。
function c56790702.initial_effect(c)
	-- ②：这张卡的攻击宣言之际，自己必须从自己墓地把1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetCost(c56790702.atcost)
	e1:SetOperation(c56790702.atop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：除外的自己的卡是3张的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56790702,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,56790702)
	e2:SetCondition(c56790702.spcon)
	e2:SetTarget(c56790702.sptg)
	e2:SetOperation(c56790702.spop)
	c:RegisterEffect(e2)
end
-- 定义攻击宣言代价的检测函数
function c56790702.atcost(e,c,tp)
	-- 检查自己墓地是否存在至少1张可以作为代价除外的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义攻击宣言时代价的具体执行操作
function c56790702.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张可以作为代价除外的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示作为代价除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤效果的发动条件函数
function c56790702.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己被除外的卡片数量是否刚好等于3张
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_REMOVED,0,nil)==3
end
-- 定义特殊召唤效果的靶向与发动准备函数
function c56790702.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表明此效果的处理为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤效果的效果处理函数
function c56790702.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
