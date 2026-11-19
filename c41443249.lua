--R－ACEプリベンター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己墓地把1张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，自己场上有其他的「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：这张卡被送去墓地的场合，以8星怪兽以外的自己的除外状态的1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：依次注册手卡特召的①效果、二速盖放对方效果怪兽的②效果以及被送墓时特召除外怪兽的③效果，各自限制1回合只能使用1次。
function s.initial_effect(c)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：从自己墓地把1张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的①②③的效果1回合各能使用1次。②：自己·对方回合，自己场上有其他的「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。
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
	-- 这个卡名的①②③的效果1回合各能使用1次。③：这张卡被送去墓地的场合，以8星怪兽以外的自己的除外状态的1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 过滤函数：判断卡片是否为「救援ACE队」卡且可以作为代价除外。
function s.costfilter(c)
	return c:IsSetCard(0x18b) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理函数：从自己墓地选择1张「救援ACE队」卡表侧除外。
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价可行性检测：检查自己墓地是否存在至少1张可作为代价除外的「救援ACE队」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向自己发送选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张可除外的「救援ACE队」卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡作为发动代价以表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标处理函数（可行性检测部分）：检查自己怪兽区域是否有空位且手卡中的这张卡能否被特殊召唤。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：检查自己怪兽区域是否至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计将手卡中的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理函数：若这张卡仍与效果有联系，则将其以表侧表示特殊召唤到自己场上。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡从手卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断怪兽是否为表侧表示的「救援ACE队」怪兽。
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b)
end
-- ②效果的发动条件判定：检查自己怪兽区域是否存在这张卡以外的表侧表示「救援ACE队」怪兽。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1只除这张卡以外的表侧表示「救援ACE队」怪兽。
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：判断怪兽是否为表侧表示的效果怪兽且能变成里侧表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsType(TYPE_EFFECT)
end
-- ②效果的对象选择与目标处理函数：以对方场上1只符合条件的效果怪兽为对象，并申报改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
	-- 发动可行性检测：检查对方场上是否存在至少1只可成为对象的表侧表示效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向自己发送选择提示，提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择对方场上1只表侧表示的效果怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：预计改变选中的1只对方怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的效果处理函数：若对象怪兽仍与效果有联系，则将其变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数：判断卡片是否为表侧除外状态的8星以外的「救援ACE队」怪兽且能被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and not c:IsLevel(8) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标处理函数（可行性检测部分）：检查自己怪兽区是否有空位且除外区存在可作为对象的目标怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动可行性检测：检查自己怪兽区域是否至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己的除外区是否存在至少1只可作为对象的8星以外的「救援ACE队」怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向自己发送选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的除外区选择1只符合条件的「救援ACE队」怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：预计将选中的除外状态怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的效果处理函数：若对象怪兽仍与效果有联系，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的除外状态怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
