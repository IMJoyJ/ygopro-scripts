--インフェルノイド・リリス
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地3只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
-- ①：这张卡特殊召唤时才能发动。「炼狱」卡以外的场上的魔法·陷阱卡全部破坏。
-- ②：1回合1次，这张卡以外的怪兽的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效并除外。
function c23440231.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地3只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c23440231.spcon)
	e2:SetTarget(c23440231.sptg)
	e2:SetOperation(c23440231.spop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤时才能发动。「炼狱」卡以外的场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c23440231.destg)
	e3:SetOperation(c23440231.desop)
	c:RegisterEffect(e3)
	-- 1回合1次，这张卡以外的怪兽的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效并除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCountLimit(1)
	e4:SetCondition(c23440231.negcon)
	e4:SetCost(c23440231.negcost)
	-- 设置②效果发动时需要选择无效对象的Target函数，使用aux.nbtg在发动时检查并声明要无效并除外的效果（包括墓地发动的效果需要追加墓地操作分类）。
	e4:SetTarget(aux.nbtg)
	e4:SetOperation(c23440231.negop)
	c:RegisterEffect(e4)
end
-- 筛选可作为特殊召唤代价除外的「狱火机」怪兽：必须是「狱火机」怪兽且能够作为代价除外。
function c23440231.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 筛选自己场上表侧表示的效果怪兽，用于计算等级·阶级合计。
function c23440231.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级·阶级数值：超量怪兽返回阶级，其他怪兽返回等级。
function c23440231.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤规则的条件：自己场上的效果怪兽等级·阶级合计在8以下，且存在3只可作为代价除外的「狱火机」怪兽（可能在手卡/墓地，若有相关效果也含场上），除后仍有怪兽区空位。
function c23440231.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上表侧表示效果怪兽的等级·阶级合计值。
	local sum=Duel.GetMatchingGroup(c23440231.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c23440231.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取手卡/墓地中可作为特殊召唤代价除外的「狱火机」怪兽集合（排除自身；若适用也包含场上）。
	local g=Duel.GetMatchingGroup(c23440231.spfilter,tp,loc,0,c)
	-- 检查该集合中是否存在3张怪兽，将其除外后自己场上仍有可用怪兽区域，满足特殊召唤条件。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤规则的选择/目标函数：让玩家从可用的「狱火机」怪兽中选择3张作为特殊召唤代价，将选择结果保存到效果标签中；只有选择成功才能进行特殊召唤。
function c23440231.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取可选作代价的「狱火机」怪兽集合（同上，排除自身）。
	local g=Duel.GetMatchingGroup(c23440231.spfilter,tp,loc,0,c)
	-- 给玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从集合中选择一组3张怪兽，要求选择后仍然有怪兽区空位，作为特殊召唤的代价。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：将之前选择好的3张「狱火机」怪兽除外，完成特殊召唤手续。
function c23440231.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为特殊召唤代价的3只怪兽表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 筛选可被①效果破坏的魔法·陷阱卡：里侧表示的卡，或不是「炼狱」卡的卡。
function c23440231.desfilter(c)
	return (c:IsFacedown() or not c:IsSetCard(0xc5)) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动目标函数：确认存在符合条件的魔法·陷阱卡，并将场上所有符合条件的魔法·陷阱卡设为破坏对象，写入操作信息。
function c23440231.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上是否存在至少1张可被破坏的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c23440231.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取场上所有可被破坏的魔法·陷阱卡（用于设定操作信息）。
	local g=Duel.GetMatchingGroup(c23440231.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的操作信息，破坏对象为g中的全部卡，数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的发动处理：实际破坏场上所有符合条件的魔法·陷阱卡。
function c23440231.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取场上所有可被破坏的魔法·陷阱卡，进行处理。
	local g=Duel.GetMatchingGroup(c23440231.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将获取到的这些卡以效果破坏送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：本卡未被战斗破坏，发动效果的怪兽不是本卡自身，且该效果是怪兽效果，并且该连锁可以被无效。
function c23440231.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:GetHandler()~=e:GetHandler()
		-- 进一步确认被连锁的是怪兽效果，且该效果发动可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 筛选可作为解放代价的怪兽：排除已处于战斗破坏状态的怪兽。
function c23440231.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的cost函数：从自己场上选1只可解放的怪兽解放；先检查是否有可解放怪兽，再选择并解放。
function c23440231.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：自己场上是否存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c23440231.cfilter,1,nil) end
	-- 选择自己场上1只可解放的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c23440231.cfilter,1,1,nil)
	-- 将选择的怪兽解放，支付②效果的发动cost。
	Duel.Release(g,REASON_COST)
end
-- ②效果处理：无效被连锁的怪兽效果的发动，并将发动该效果的怪兽除外；若无效成功且该怪兽仍与效果关联则除外。
function c23440231.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该连锁的发动，且发动效果的那只怪兽仍存在于场上/与效果联动。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的怪兽以表侧表示除外，完成除外处理。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
