--R－ACEプリベンター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己墓地把1张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，自己场上有其他的「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：这张卡被送去墓地的场合，以8星怪兽以外的自己的除外状态的1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡创建并注册三个效果——①手卡起动的自身特殊召唤效果、②二速将对方效果怪兽变里侧守备的效果、③送墓时特殊召唤除外区救援ACE队怪兽的效果。
function s.initial_effect(c)
	-- ①：从自己墓地把1张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sscost)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，自己场上有其他的「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以8星怪兽以外的自己的除外状态的1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 代价筛选函数：判断墓地中的卡是否为「救援ACE队」字段卡且可以作为代价除外。
function s.costfilter(c)
	return c:IsSetCard(0x18b) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价函数：发动前检查墓地是否存在可除外的「救援ACE队」卡，发动时提示玩家选择1张并除外作为代价。
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查分支：确认自己的墓地存在至少1张满足costfilter的「救援ACE队」卡，即可作为代价发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足costfilter的「救援ACE队」卡作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标函数：确认自己主要怪兽区有空位，且这张卡本身可以被特殊召唤；无需选择对象，仅设置特殊召唤信息。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本次效果处理为将这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：若这张卡仍与效果关联，则将其特殊召唤。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 条件筛选函数：判断怪兽是否表侧表示且拥有「救援ACE队」字段，用于②效果的条件检测。
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b)
end
-- ②效果的条件函数：确认自己场上有其他表侧表示的「救援ACE队」怪兽存在。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张除自身以外的表侧表示「救援ACE队」怪兽。
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- ②效果的对象筛选函数：对方场上的表侧表示效果怪兽，且可以变为里侧守备表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsType(TYPE_EFFECT)
end
-- ②效果的目标函数：取对象选择对方场上1只满足posfilter的效果怪兽，并设置将其改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
	-- 目标检查分支：确认对方场上存在至少1只可以作为对象的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，要求选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从对方场上选择1只效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，标明本次效果处理为将对象怪兽改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的处理函数：取得对象，若对象仍与效果关联，则将其变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中记录的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ③效果的对象筛选函数：从自己除外区选择表侧表示的「救援ACE队」怪兽，要求等级不是8星，且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and not c:IsLevel(8) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标函数：确认主要怪兽区有空位，并从自己除外区选择1只满足spfilter的「救援ACE队」怪兽作为对象（注意代码中误写为s.filter，实际应引用spfilter）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在至少1只满足spfilter的「救援ACE队」怪兽可以作为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己除外区选择1只满足spfilter的「救援ACE队」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，标明本次效果处理为将选择的对象特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的处理函数：取得对象，若对象仍与效果关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中记录的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
