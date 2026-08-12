--ダイノルフィア・ディプロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「恐啡肽狂龙」卡送去墓地。自己基本分是2000以下的场合，再给与对方500伤害。
-- ②：这张卡被战斗·效果破坏的场合，从自己墓地把1张陷阱卡除外才能发动。从自己墓地选「恐啡肽狂龙·梁龙」以外的1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
function c38628859.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「恐啡肽狂龙」卡送去墓地。自己基本分是2000以下的场合，再给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38628859)
	e1:SetTarget(c38628859.tgtg)
	e1:SetOperation(c38628859.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合，从自己墓地把1张陷阱卡除外才能发动。从自己墓地选「恐啡肽狂龙·梁龙」以外的1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,38628860)
	e3:SetCondition(c38628859.spcon)
	e3:SetCost(c38628859.spcost)
	e3:SetTarget(c38628859.sptg)
	e3:SetOperation(c38628859.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选可以送去墓地的「恐啡肽狂龙」卡
function c38628859.tgfilter(c)
	return c:IsSetCard(0x173) and c:IsAbleToGrave()
end
-- 设置效果处理时要送去墓地的卡和可能造成伤害的处理信息
function c38628859.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「恐啡肽狂龙」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38628859.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 判断自己基本分是否小于等于2000
	if Duel.GetLP(tp)<=2000 then
		-- 设置将要给对方造成500伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
-- 处理效果发动时的卡组检索和伤害处理
function c38628859.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择一张「恐啡肽狂龙」卡
	local g=Duel.SelectMatchingCard(tp,c38628859.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的卡已成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 确认自己基本分小于等于2000
		and Duel.GetLP(tp)<=2000 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 给对方造成500伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 判断破坏原因是否为战斗或效果
function c38628859.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤函数，用于筛选可以作为除外代价的陷阱卡
function c38628859.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 处理效果发动时的除外代价
function c38628859.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38628859.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择一张陷阱卡除外
	local g=Duel.SelectMatchingCard(tp,c38628859.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将陷阱卡从墓地除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选可以特殊召唤的「恐啡肽狂龙」怪兽
function c38628859.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and not c:IsCode(38628859) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要特殊召唤的卡
function c38628859.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c38628859.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理效果发动时的特殊召唤
function c38628859.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c38628859.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
