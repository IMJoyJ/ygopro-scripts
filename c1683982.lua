--毒蛇の怨念
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，爬虫类族以外的自己怪兽不能攻击，不能把效果发动。
-- ②：自己场上的表侧表示的爬虫类族怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从卡组把1只4星以下的爬虫类族怪兽特殊召唤。
-- ③：魔法与陷阱区域的这张卡被破坏的场合才能发动。除外的自己的爬虫类族怪兽全部回到墓地。
function c1683982.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，爬虫类族以外的自己怪兽不能攻击。（本段实现“不能攻击”部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c1683982.atktg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的爬虫类族怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从卡组把1只4星以下的爬虫类族怪兽特殊召唤。（此段对应“被战斗破坏的场合”分支）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1683982,1))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,1683982)
	e3:SetCondition(c1683982.spcon)
	e3:SetTarget(c1683982.sptg)
	e3:SetOperation(c1683982.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c1683982.spcon2)
	c:RegisterEffect(e4)
	-- ③：魔法与陷阱区域的这张卡被破坏的场合才能发动。除外的自己的爬虫类族怪兽全部回到墓地。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(1683982,2))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCountLimit(1,1683983)
	e6:SetCondition(c1683982.tgcon)
	e6:SetTarget(c1683982.tgtg)
	e6:SetOperation(c1683982.tgop)
	c:RegisterEffect(e6)
end
-- 判定怪兽是否为爬虫类族以外，若不属于爬虫类族则适用①不能攻击的限制。
function c1683982.atktg(e,c)
	return not c:IsRace(RACE_REPTILE)
end
-- ②战破分支的过滤条件：怪兽被战斗破坏、之前控制者为自己、在场上时的种族为爬虫类族。
function c1683982.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE) and c:GetPreviousRaceOnField()&RACE_REPTILE~=0
end
-- ②战破分支的发动条件：本次破坏的怪兽组中存在满足cfilter的爬虫类族怪兽。
function c1683982.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1683982.cfilter,1,nil,tp)
end
-- ②送墓分支的过滤条件：怪兽非战斗破坏、之前控制者为自己、之前位于主要怪兽区、在场上时原种族为爬虫类族、现在仍为爬虫类族、且之前为表侧表示。
function c1683982.cfilter2(c,tp)
	return not c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousRaceOnField()&RACE_REPTILE~=0 and c:IsRace(RACE_REPTILE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②送墓分支的发动条件：本次送去墓地的怪兽组中存在满足cfilter2的爬虫类族怪兽。
function c1683982.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1683982.cfilter2,1,nil,tp)
end
-- 选择卡组中符合条件的怪兽：爬虫类族、4星以下、可以被特殊召唤。
function c1683982.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的合法条件检查：自己场上怪兽区有空位，且卡组存在符合条件的爬虫类族怪兽。
function c1683982.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1张以上符合条件的爬虫类族怪兽（4星以下且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c1683982.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁将进行特殊召唤，预定从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1只爬虫类族怪兽，以表侧表示特殊召唤到自己场上。
function c1683982.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，无空位则处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张符合条件的爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c1683982.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③发动条件：这张卡被破坏前位于魔法与陷阱区域。
function c1683982.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 筛选除外区中表侧表示的爬虫类族怪兽（用于③回到墓地）。
function c1683982.filter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup()
end
-- ③发动时点：确认除外区存在自己的表侧爬虫类族怪兽，并取得全部此类怪兽，设置送回墓地的操作信息。
function c1683982.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：除外区是否至少存在1张表侧表示的爬虫类族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1683982.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 取得除外区所有表侧表示的爬虫类族怪兽。
	local g=Duel.GetMatchingGroup(c1683982.filter,tp,LOCATION_REMOVED,0,nil)
	-- 设置操作信息：将上述怪兽全部送去墓地，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- ③效果处理：将除外区自己的表侧爬虫类族怪兽全部送回墓地。
function c1683982.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得除外区中所有表侧表示的爬虫类族怪兽。
	local g=Duel.GetMatchingGroup(c1683982.filter,tp,LOCATION_REMOVED,0,nil)
	-- 将这些怪兽全部送去墓地，送入原因视为效果并附带回到墓地的标识（REASON_EFFECT+REASON_RETURN）。
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
end
