--白銀の迷宮城
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：盖放的「拉比林斯迷宫欢迎」通常陷阱卡由自己发动的场合，可以给那个效果加上以下效果。
-- ●选场上1张卡破坏。
-- ②：自己把「拉比林斯迷宫」卡以外的通常陷阱卡发动的场合才能发动。从自己的手卡·墓地选1只恶魔族怪兽特殊召唤。
function c33407125.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：盖放的「拉比林斯迷宫欢迎」通常陷阱卡由自己发动的场合，可以给那个效果加上以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(33407125)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,33407125)
	c:RegisterEffect(e1)
	-- ②：自己把「拉比林斯迷宫」卡以外的通常陷阱卡发动的场合才能发动。从自己的手卡·墓地选1只恶魔族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33407125,1))  --"恶魔族怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,33407126)
	e2:SetCondition(c33407125.spcon)
	e2:SetTarget(c33407125.sptg)
	e2:SetOperation(c33407125.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断：确认是自己发动的陷阱卡且不是「拉比林斯迷宫」系列的卡。
function c33407125.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and not rc:IsSetCard(0x17e) and rc:GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 筛选满足条件的恶魔族怪兽，用于特殊召唤。
function c33407125.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的处理条件：场上存在空位且手牌或墓地有恶魔族怪兽。
function c33407125.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在满足条件的恶魔族怪兽。
		and Duel.IsExistingMatchingCard(c33407125.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤恶魔族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数：选择并特殊召唤恶魔族怪兽。
function c33407125.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择一张满足条件的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33407125.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
