--ジェムナイト・プリズムオーラ
-- 效果：
-- 「宝石骑士」怪兽＋雷族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，从手卡把1张「宝石骑士」卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
function c93379652.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为1只「宝石骑士」怪兽和1只雷族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),aux.FilterBoolFunction(Card.IsRace,RACE_THUNDER),true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c93379652.splimit)
	c:RegisterEffect(e2)
	-- ①：1回合1次，从手卡把1张「宝石骑士」卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93379652,0))  --"表侧表示的1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c93379652.cost)
	e3:SetTarget(c93379652.target)
	e3:SetOperation(c93379652.operation)
	c:RegisterEffect(e3)
end
-- 限制此卡从额外卡组特殊召唤时必须使用融合召唤
function c93379652.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 过滤手牌中可以作为代价送去墓地的「宝石骑士」卡
function c93379652.costfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价：从手卡把1张「宝石骑士」卡送去墓地
function c93379652.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张可以作为代价送去墓地的「宝石骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93379652.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1张「宝石骑士」卡
	local g=Duel.SelectMatchingCard(tp,c93379652.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤场上表侧表示的卡
function c93379652.filter(c)
	return c:IsFaceup()
end
-- 效果发动的目标：选择场上1张表侧表示的卡为对象，并设置破坏操作信息
function c93379652.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c93379652.filter(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c93379652.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c93379652.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：将作为对象的表侧表示卡破坏
function c93379652.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
