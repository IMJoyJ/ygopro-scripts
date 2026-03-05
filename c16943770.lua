--幻獣機エアロスバード
-- 效果：
-- ①：1回合1次，把「幻兽机 航空飞鸟」以外的自己墓地1只「幻兽机」怪兽除外才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
function c16943770.initial_effect(c)
	-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c16943770.lvval)
	c:RegisterEffect(e1)
	-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 判断场上是否存在衍生物，若存在则此效果生效。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：1回合1次，把「幻兽机 航空飞鸟」以外的自己墓地1只「幻兽机」怪兽除外才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16943770,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c16943770.spcost)
	e4:SetTarget(c16943770.sptg)
	e4:SetOperation(c16943770.spop)
	c:RegisterEffect(e4)
end
-- 计算场上所有幻兽机衍生物的等级总和作为当前卡片等级提升值。
function c16943770.lvval(e,c)
	local tp=c:GetControler()
	-- 获取场上所有幻兽机衍生物并计算其等级总和。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 过滤条件：墓地中的幻兽机卡牌且不是自身，且可以作为除外的代价。
function c16943770.cfilter(c)
	return c:IsSetCard(0x101b) and not c:IsCode(16943770) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：选择并除外1张符合条件的墓地幻兽机卡牌作为发动代价。
function c16943770.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：墓地是否存在符合条件的幻兽机卡牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c16943770.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择1张符合条件的幻兽机卡牌。
	local g=Duel.SelectMatchingCard(tp,c16943770.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡牌从墓地除外作为效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤衍生物的效果目标。
function c16943770.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤幻兽机衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置连锁操作信息：将要特殊召唤1个衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：将要特殊召唤1个衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：若满足条件则创建并特殊召唤1个幻兽机衍生物。
function c16943770.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤幻兽机衍生物。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建一个幻兽机衍生物。
		local token=Duel.CreateToken(tp,16943771)
		-- 将创建的衍生物特殊召唤到场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
