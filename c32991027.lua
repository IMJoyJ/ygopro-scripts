--氷結界の剣士 ゲオルギアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只5星以下的「冰结界」怪兽特殊召唤。
-- ③：只要自己场上有其他的「冰结界」怪兽存在，对方不能把墓地的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化函数：创建并注册该卡的①手卡起动效果将自身特殊召唤、②召唤/特殊召唤成功时从手卡·墓地特殊召唤1只5星以下冰结界怪兽（e2/e3分别处理召唤/特殊召唤）、③限制对方发动墓地怪兽效果的永续效果。
function s.initial_effect(c)
	-- ①：自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只5星以下的「冰结界」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要自己场上有其他的「冰结界」怪兽存在，对方不能把墓地的怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断卡片是否为表侧表示的「冰结界」怪兽（用于检查场上是否存在冰结界怪兽）。
function s.cfilter(c)
	return c:IsSetCard(0x2f) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有表侧表示的「冰结界」怪兽存在时允许发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「冰结界」怪兽，作为①效果的发动条件。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时判定：自己场上有空余的主要怪兽区，并且这张卡可以被特殊召唤为表侧守备表示。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置①效果的操作信息：预定将这张卡特殊召唤，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，将其以表侧守备表示从手卡特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的筛选函数：选择手卡·墓地中等级5以下的「冰结界」怪兽，并确认其可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时判定：自己场上有空余的主要怪兽区，且手卡·墓地存在符合条件的「冰结界」怪兽可供特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在至少1只满足spfilter条件的5星以下「冰结界」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置②效果的操作信息：预定从手卡·墓地特殊召唤1只「冰结界」怪兽（目标暂不确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：若仍有空位，提示玩家选择手卡·墓地的1只5星以下「冰结界」怪兽，并以表侧攻击表示特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有空余怪兽区，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择卡片提示，提示文字为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只5星以下且可特殊召唤的「冰结界」怪兽（通过NecroValleyFilter过滤受王家长眠之谷影响的墓地卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将玩家选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的条件：自己场上有其他表侧表示的「冰结界」怪兽存在（不包括自身）时，③效果适用。
function s.actcon(e)
	-- 检查自己场上是否存在除自身以外的表侧表示「冰结界」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- ③效果的禁止条件：对方发动的效果必须是从墓地发动的怪兽效果时，才被禁止发动（即对方不能发动墓地怪兽的效果）。
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE and re:IsActiveType(TYPE_MONSTER)
end
