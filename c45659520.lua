--E-HERO シニスター・ネクロム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外才能发动。从手卡·卡组把「邪心英雄 凶灵尸魔」以外的1只「邪心英雄」怪兽特殊召唤。
function c45659520.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把墓地的这张卡除外才能发动。从手卡·卡组把「邪心英雄 凶灵尸魔」以外的1只「邪心英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45659520,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,45659520)
	-- 设置效果的发动代价为把墓地的这张卡除外；发动前将自身从墓地除外作为COST。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45659520.target)
	e1:SetOperation(c45659520.operation)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤对象的筛选条件：必须是「邪心英雄」系列怪兽（卡名含有0x6008）、不是这张卡自身（卡号为45659520）、并且能够被当前效果特殊召唤。
function c45659520.filter(c,e,tp)
	return c:IsSetCard(0x6008) and not c:IsCode(45659520) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的target函数，用于判定发动是否合法并登记预期处理；在chk==0时检查主要怪兽区有空位且手卡·卡组中存在符合条件的「邪心英雄」怪兽。
function c45659520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空格，确保有特殊召唤的场地。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方手卡·卡组中是否存在至少1只满足c45659520.filter条件的「邪心英雄」怪兽（不取对象，仅作存在判定）。
		and Duel.IsExistingMatchingCard(c45659520.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，声明本效果处理时将进行特殊召唤，预定从手卡·卡组特殊召唤1只怪兽（持有者为tp）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数：实际执行特殊召唤流程，包括确认场地、提示玩家选择、从手卡·卡组选出符合条件的「邪心英雄」怪兽并特殊召唤到场上。
function c45659520.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否仍有空位，若没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家自己的手卡·卡组中选取1只满足c45659520.filter条件的「邪心英雄」怪兽（排除「邪心英雄 凶灵尸魔」）。
	local sg=Duel.SelectMatchingCard(tp,c45659520.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if sg:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到玩家自己的场上（默认表侧攻击表示）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
