--精霊獣使い レラ
-- 效果：
-- 自己对「精灵兽使 蕾拉」1回合只能有1次特殊召唤，那些①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。进行手卡1只「灵兽」怪兽的召唤。
-- ②：自己场上的「灵兽」卡被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
-- ③：这张卡被除外的场合才能发动。从卡组把「精灵兽使 蕾拉」以外的1只「灵兽」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的三个效果，分别对应①②③效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- ①：把这张卡从手卡丢弃才能发动。进行手卡1只「灵兽」怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"进行「灵兽」怪兽的召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「灵兽」卡被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合才能发动。从卡组把「精灵兽使 蕾拉」以外的1只「灵兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果发动时，将自身从手卡丢弃作为代价
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身送入墓地，作为效果的发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 召唤效果的过滤函数，用于筛选手卡中可通常召唤的「灵兽」怪兽
function s.filter(c)
	return c:IsSetCard(0xb5) and c:IsSummonable(true,nil)
end
-- 设置召唤效果的目标，检查是否存在满足条件的「灵兽」怪兽
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「灵兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置效果处理信息，表示将要进行一次通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 执行召唤效果的操作，选择并通常召唤一只「灵兽」怪兽
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要通常召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 对选中的怪兽进行通常召唤
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
-- 代替破坏效果的过滤函数，用于判断是否为「灵兽」怪兽
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
		and c:IsSetCard(0xb5) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标判定函数，检查是否有符合条件的怪兽被破坏
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的值函数，返回是否满足代替条件
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果的操作，将自身除外
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身从场上除外，作为代替破坏的效果
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
-- 特殊召唤效果的过滤函数，用于筛选卡组中可特殊召唤的「灵兽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 设置特殊召唤效果的目标，检查卡组中是否存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要进行一次特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果的操作，选择并特殊召唤一只「灵兽」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
