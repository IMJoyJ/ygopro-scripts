--R－ACEプリベンター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己墓地把1张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，自己场上有其他的「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：这张卡被送去墓地的场合，以8星怪兽以外的自己的除外状态的1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册三个效果，分别对应①②③效果
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
-- 过滤函数，用于检索满足条件的「救援ACE队」卡
function s.costfilter(c)
	return c:IsSetCard(0x18b) and c:IsAbleToRemoveAsCost()
end
-- ①效果的费用处理，从墓地选择1张「救援ACE队」卡除外
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件判断
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于检索场上存在的「救援ACE队」怪兽
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b)
end
-- ②效果的发动条件判断
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在其他「救援ACE队」怪兽
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数，用于检索可以改变表示形式的效果怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsType(TYPE_EFFECT)
end
-- ②效果的发动处理
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，准备改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的处理函数
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数，用于检索满足条件的除外状态的「救援ACE队」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and not c:IsLevel(8) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动处理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的除外状态的「救援ACE队」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
