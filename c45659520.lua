--E-HERO シニスター・ネクロム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外才能发动。从手卡·卡组把「邪心英雄 凶灵尸魔」以外的1只「邪心英雄」怪兽特殊召唤。
function c45659520.initial_effect(c)
	-- ①：把墓地的这张卡除外才能发动。从手卡·卡组把「邪心英雄 凶灵尸魔」以外的1只「邪心英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45659520,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,45659520)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45659520.target)
	e1:SetOperation(c45659520.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「邪心英雄」怪兽（不包括自身）且可以被特殊召唤
function c45659520.filter(c,e,tp)
	return c:IsSetCard(0x6008) and not c:IsCode(45659520) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c45659520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c45659520.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c45659520.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local sg=Duel.SelectMatchingCard(tp,c45659520.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if sg:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
