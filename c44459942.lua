--ニコイチ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地把1只机械族·暗属性怪兽除外才能发动。把有「马达衍生物」的衍生物名记述的1只怪兽从自己的手卡·卡组·墓地特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的机械族·暗属性怪兽被战斗以外送去墓地的场合，把这张卡除外才能发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
local s,id,o=GetID()
-- 初始化效果，注册两个效果，分别为①效果和②效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载着「马达衍生物」（卡号82556059）
	aux.AddCodeList(c,82556059)
	-- ①效果：从自己墓地把1只机械族·暗属性怪兽除外才能发动。把有「马达衍生物」的衍生物名记述的1只怪兽从自己的手卡·卡组·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②效果：这张卡在墓地存在的状态，自己场上的表侧表示的机械族·暗属性怪兽被战斗以外送去墓地的场合，把这张卡除外才能发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- ②效果的发动费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地是否有满足条件的机械族·暗属性怪兽可以作为①效果的除外费用
function s.cfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
		-- 检查是否有满足条件的「马达衍生物」怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
-- ①效果的发动费用处理，选择并除外1只满足条件的机械族·暗属性怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的发动条件，即墓地是否有满足条件的机械族·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的机械族·暗属性怪兽并除外
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 执行除外操作
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断是否为「马达衍生物」怪兽且可以特殊召唤
function s.spfilter(c,e,tp)
	-- 判断是否为「马达衍生物」怪兽且可以特殊召唤
	return aux.IsCodeListed(c,82556059) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判断，检查是否有满足条件的「马达衍生物」怪兽可以特殊召唤
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的「马达衍生物」怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只「马达衍生物」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的发动处理，选择并特殊召唤1只「马达衍生物」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「马达衍生物」怪兽并特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否为满足条件的机械族·暗属性怪兽且被战斗以外方式送入墓地
function s.cspfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_DARK)~=0
		and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_BATTLE)
end
-- ②效果的发动条件判断，检查是否有满足条件的机械族·暗属性怪兽被战斗以外方式送入墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cspfilter,1,nil,tp)
end
-- ②效果的发动条件判断，检查是否可以特殊召唤「马达衍生物」token
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤「马达衍生物」token
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK,tp,0) end
	-- 设置操作信息，表示将要特殊召唤1只「马达衍生物」token
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息，表示将要生成1个「马达衍生物」token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ②效果的发动处理，生成并特殊召唤1个「马达衍生物」token
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤「马达衍生物」token
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK,tp,0) then
		-- 创建「马达衍生物」token
		local token=Duel.CreateToken(tp,id+o)
		-- 执行特殊召唤token操作
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
