--デフラドラグーン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只其他怪兽送去墓地，从手卡特殊召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把这张卡以外的3只同名怪兽除外才能发动。这张卡从墓地特殊召唤。
function c58582979.initial_effect(c)
	-- ①：这张卡可以把手卡1只其他怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,58582979+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c58582979.hspcon)
	e1:SetTarget(c58582979.hsptg)
	e1:SetOperation(c58582979.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己墓地把这张卡以外的3只同名怪兽除外才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,58582980)
	e2:SetCost(c58582979.spcost)
	e2:SetTarget(c58582979.sptg)
	e2:SetOperation(c58582979.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以作为特殊召唤代价送去墓地的怪兽
function c58582979.hspcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的判定条件函数
function c58582979.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除自身以外、可以送去墓地的怪兽
		and Duel.IsExistingMatchingCard(c58582979.hspcfilter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的玩家选择目标处理函数
function c58582979.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外、可以送去墓地的怪兽组
	local g=Duel.GetMatchingGroup(c58582979.hspcfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作处理函数
function c58582979.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 过滤自己墓地中可以作为除外代价的怪兽，且墓地中还存在另外2张与其同名的卡
function c58582979.spcfilter1(c,tp,ec)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在另外2张与该怪兽同名且可以除外的卡（排除自身和第一张选定的卡）
		and Duel.IsExistingMatchingCard(c58582979.spcfilter2,tp,LOCATION_GRAVE,0,2,Group.FromCards(ec,c),c:GetCode())
end
-- 过滤墓地中与指定卡同名且可以除外的卡
function c58582979.spcfilter2(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价（Cost）处理函数
function c58582979.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，确认墓地中是否存在满足除外条件的3只同名怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58582979.spcfilter1,tp,LOCATION_GRAVE,0,1,c,tp,c) end
	-- 提示玩家选择要除外的第一只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择第一只作为除外代价的怪兽
	local g=Duel.SelectMatchingCard(tp,c58582979.spcfilter1,tp,LOCATION_GRAVE,0,1,1,c,tp,c)
	-- 提示玩家选择要除外的另外两只同名怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择另外2只与第一只怪兽同名的怪兽
	local g2=Duel.SelectMatchingCard(tp,c58582979.spcfilter2,tp,LOCATION_GRAVE,0,2,2,Group.FromCards(c,g:GetFirst()),g:GetFirst():GetCode())
	g:Merge(g2)
	-- 将选定的3只同名怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动检查与效果注册（Target）函数
function c58582979.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c58582979.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
