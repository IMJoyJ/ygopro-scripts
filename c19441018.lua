--電池メン－業務用
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只名字带有「电池人」的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，把自己墓地1只雷族怪兽从游戏中除外才能发动。选择场上1只怪兽和1张魔法·陷阱卡破坏。
function c19441018.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己墓地2只名字带有「电池人」的怪兽从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19441018.spcon)
	e1:SetTarget(c19441018.sptg)
	e1:SetOperation(c19441018.spop)
	c:RegisterEffect(e1)
	-- 把自己墓地2只名字带有「电池人」的怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件恒为不满足，使这张卡不能被其他效果特殊召唤，只能通过上述EFFECT_SPSUMMON_PROC规则召唤。
	e2:SetValue(aux.FALSE)
	c:RegisterEffect(e2)
	-- 1回合1次，把自己墓地1只雷族怪兽从游戏中除外才能发动。选择场上1只怪兽和1张魔法·陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19441018,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c19441018.descost)
	e3:SetTarget(c19441018.destg)
	e3:SetOperation(c19441018.desop)
	c:RegisterEffect(e3)
end
-- 特殊召唤代价的怪兽筛选：必须是名字带有「电池人」的怪兽，且可以作为代价从墓地除外。
function c19441018.spfilter(c)
	return c:IsSetCard(0x28) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件判定：自己主要怪兽区有空位，且墓地中存在至少2只满足条件的「电池人」怪兽作为除外代价。
function c19441018.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己场上主要怪兽区存在空位，以放置通过该方法特殊召唤的怪兽。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少2只满足spfilter的「电池人」怪兽，可供除外作为特殊召唤代价。
		and Duel.IsExistingMatchingCard(c19441018.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤手续的目标选择：从墓地选出2只「电池人」怪兽作为除外代价，保存到效果标签中，供处理时除外。
function c19441018.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可作为除外代价的「电池人」怪兽，构成候选集合。
	local g=Duel.GetMatchingGroup(c19441018.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 显示选择提示，要求玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的代价执行：将目标选择的2只「电池人」怪兽从墓地除外，然后完成特殊召唤。
function c19441018.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的墓地怪兽以表侧表示除外，除外原因记录为特殊召唤的规则代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 起动效果代价的筛选：必须是雷族怪兽，且可以作为代价从墓地除外。
function c19441018.costfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：确认墓地存在可除外的雷族怪兽，选择1只除外作为效果发动成本。
function c19441018.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认墓地存在至少1只满足costfilter的雷族怪兽，以供除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c19441018.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，要求玩家选择要除外的雷族怪兽作为代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只满足条件的雷族怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c19441018.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的雷族怪兽以表侧表示除外，作为效果的发动成本。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏对象（怪兽侧）的筛选：该怪兽可作为对象，且场上还存在1张魔法·陷阱卡可作为另一个破坏对象。
function c19441018.filter1(c)
	-- 以候选怪兽为排除对象，检查场上是否存在至少1张魔法·陷阱卡可作为另一个破坏对象。
	return Duel.IsExistingTarget(c19441018.filter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 破坏对象（魔法·陷阱侧）的筛选：对象必须是魔法卡或陷阱卡。
function c19441018.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标选择：依次选择1只场上怪兽和1张场上魔法·陷阱卡，合并为破坏对象组，并设置破坏相关的连锁信息。
function c19441018.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动合法性检查：存在至少1只满足filter1的怪兽候选，且该候选能关联到可选择的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c19441018.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，要求玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只场上怪兽作为破坏对象，并通过SelectTarget将其登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c19441018.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 显示选择提示，要求玩家选择要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张场上魔法·陷阱卡作为破坏对象，排除已选怪兽后与怪兽对象合并。
	local g2=Duel.SelectTarget(tp,c19441018.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置连锁操作信息，声明本次破坏处理将要破坏2张卡，供连锁响应及效果无效等判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 破坏效果处理：取得连锁对象，过滤出仍与该效果关联的卡，将它们一并破坏。
function c19441018.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时选择的对象卡组（1只怪兽和1张魔法·陷阱卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的对象卡破坏，破坏原因记为卡片效果。
	Duel.Destroy(dg,REASON_EFFECT)
end
