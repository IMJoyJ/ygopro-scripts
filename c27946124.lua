--聖蔓の社
-- 效果：
-- 自己场上有「圣天树」连接怪兽存在的场合，把1张手卡送去墓地才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，自己不是植物族怪兽不能从额外卡组特殊召唤。
-- ②：1回合1次，可以发动。从自己墓地选1只4星以下的植物族通常怪兽特殊召唤。
-- ③：对方结束阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1张永续陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c27946124.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不是植物族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27946124.cost)
	e1:SetCondition(c27946124.con)
	c:RegisterEffect(e1)
	-- ②：1回合1次，可以发动。从自己墓地选1只4星以下的植物族通常怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c27946124.splimit)
	c:RegisterEffect(e2)
	-- ③：对方结束阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1张永续陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27946124,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c27946124.sptg)
	e3:SetOperation(c27946124.spop)
	c:RegisterEffect(e3)
	-- 自己场上有「圣天树」连接怪兽存在的场合，把1张手卡送去墓地才能把这张卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27946124,1))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCost(c27946124.setcost)
	e4:SetCondition(c27946124.setcon)
	e4:SetTarget(c27946124.settg)
	e4:SetOperation(c27946124.setop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的手卡并将其送去墓地作为发动的代价。
function c27946124.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手卡中存在可作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行将1张手卡送去墓地的操作。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 用于筛选场上的「圣天树」连接怪兽。
function c27946124.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x2158)
end
-- 检查是否满足发动条件：自己场上存在「圣天树」连接怪兽。
function c27946124.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「圣天树」连接怪兽。
	return Duel.IsExistingMatchingCard(c27946124.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 限制非植物族怪兽从额外卡组特殊召唤。
function c27946124.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_PLANT)
end
-- 用于筛选满足条件的墓地植物族通常怪兽。
function c27946124.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件。
function c27946124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的植物族通常怪兽。
		and Duel.IsExistingMatchingCard(c27946124.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作。
function c27946124.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的植物族通常怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27946124.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置盖放效果的发动代价。
function c27946124.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置盖放效果的发动条件。
function c27946124.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足发动条件：当前不是回合玩家。
	return tp~=Duel.GetTurnPlayer()
end
-- 用于筛选满足条件的永续陷阱卡。
function c27946124.setfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsSSetable(true)
end
-- 设置盖放效果的发动条件。
function c27946124.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27946124.setfilter(chkc) end
	-- 检查是否有足够的魔法与陷阱区域进行盖放。
	if chk==0 then return Duel.GetSZoneCount(tp,e:GetHandler())>0
		-- 检查墓地中是否存在满足条件的永续陷阱卡。
		and Duel.IsExistingTarget(c27946124.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从墓地中选择满足条件的永续陷阱卡。
	local sg=Duel.SelectTarget(tp,c27946124.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置盖放效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
-- 执行盖放操作。
function c27946124.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡在自己的魔法与陷阱区域盖放。
		Duel.SSet(tp,tc)
	end
end
