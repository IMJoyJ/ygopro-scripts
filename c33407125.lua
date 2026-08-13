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
	-- 对应效果原文“这个卡名的①②的效果1回合各能使用1次。”（此处通过自定义效果码33407125设置①效果的1回合次数限制）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(33407125)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,33407125)
	c:RegisterEffect(e1)
	-- 对应效果原文“②：自己把「拉比林斯迷宫」卡以外的通常陷阱卡发动的场合才能发动。从自己的手卡·墓地选1只恶魔族怪兽特殊召唤。”（e2的SetCountLimit(1,33407126)对应②的1回合1次限制）
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
-- ②效果的发动条件：必须是己方发动了不属于「拉比林斯迷宫」系列、且为通常陷阱卡的卡的发动（re为魔法陷阱卡的发动），才满足诱发条件。
function c33407125.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and not rc:IsSetCard(0x17e) and rc:GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 筛选特殊召唤对象：怪兽的种族为恶魔族，并且能够被当前效果特殊召唤（检查召唤条件与苏生限制）。
function c33407125.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时机检查合法性：自己主要怪兽区域有空位，同时手卡或墓地存在至少1只符合条件的恶魔族怪兽。
function c33407125.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否还有空位，作为②效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在至少1只满足spfilter过滤条件的恶魔族怪兽（不取对象，实际卡在处理时选择）。
		and Duel.IsExistingMatchingCard(c33407125.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：该效果包含“特殊召唤”分类，预期从手卡/墓地特殊召唤1只怪兽（不取对象，处理时选定），供相关效果和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的实际处理：若仍有空位，则让玩家从手卡·墓地选择1只符合条件的恶魔族怪兽，将其表侧表示特殊召唤到自己场上；选择时排除受王家长眠之谷影响而无法特殊召唤的卡。
function c33407125.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区域有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，让玩家进行选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·墓地中选出1张符合条件的恶魔族怪兽；这里使用aux.NecroValleyFilter，受王家长眠之谷影响的卡不会被选中。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33407125.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上，不无视召唤条件与苏生限制（nocheck=false, nolimit=false）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
