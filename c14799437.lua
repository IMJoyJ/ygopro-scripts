--インフェルノイド・ネヘモス
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地3只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
-- ①：这张卡特殊召唤时才能发动。场上的其他怪兽全部破坏。
-- ②：1回合1次，魔法·陷阱卡的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效并除外。
function c14799437.initial_effect(c)
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
	e2:SetCondition(c14799437.spcon)
	e2:SetTarget(c14799437.sptg)
	e2:SetOperation(c14799437.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤时才能发动。场上的其他怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14799437,0))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c14799437.destg)
	e3:SetOperation(c14799437.desop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，魔法·陷阱卡的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效并除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14799437,1))  --"魔法·陷阱卡的发动无效并除外"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCountLimit(1)
	e4:SetCondition(c14799437.negcon)
	e4:SetCost(c14799437.negcost)
	-- 设置②效果的目标函数为通用无效并除外判定（aux.nbtg），用于检验并声明将发动的魔法·陷阱卡的发动无效并除外，若对象在墓地发动则补充墓地操作分类。
	e4:SetTarget(aux.nbtg)
	e4:SetOperation(c14799437.negop)
	c:RegisterEffect(e4)
end
-- 筛选可用于特殊召唤代价除外的「狱火机」怪兽：需满足字段「狱火机」（0xbb）、是怪兽卡，且可以作为代价除外（IsAbleToRemoveAsCost）。
function c14799437.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 筛选场上表侧表示的效果怪兽，用于后续累加等级/阶级数值以检查是否在8以下。
function c14799437.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取卡片的阶级（XYZ怪兽）或等级（非XYZ怪兽），用于将场上效果怪兽的等级·阶级合计。
function c14799437.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤规则发动条件的判定：自身场上的表侧效果怪兽等级·阶级合计不超过8；且从规定位置（手卡·墓地，若有指定卡号效果则含场上）存在3只可作为代价除外的「狱火机」怪兽，且选择它们除完后自己场上仍有怪兽区域空位。
function c14799437.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算自己场上表侧表示效果怪兽的等级·阶级合计值，用于判断是否≤8。
	local sum=Duel.GetMatchingGroup(c14799437.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c14799437.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取可用于除外的「狱火机」怪兽候选集合（位置为手卡·墓地，若适用则含场上，并排除自身），供特殊召唤手续使用。
	local g=Duel.GetMatchingGroup(c14799437.spfilter,tp,loc,0,c)
	-- 检查候选集合中是否存在3张一组，使这3张作为代价除外后自己场上仍保留怪兽区域空位（满足aux.mzctcheck），从而满足特殊召唤条件。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤手续的目标选择：从候选集合中让玩家选择3只「狱火机」怪兽作为除外代价，要求选择后场上仍有怪兽区域空位；若选择成功则将选择组保存到效果标签并返回true，否则false。
function c14799437.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 在目标选择时再次获取可除外的「狱火机」怪兽候选集合（手卡·墓地，适用时含场上，排除自身），供玩家选择。
	local g=Duel.GetMatchingGroup(c14799437.spfilter,tp,loc,0,c)
	-- 向玩家显示“请选择要除外的卡”的提示，要求其选择用于特殊召唤代价的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从候选集合中选择3张「狱火机」怪兽，同时用aux.mzctcheck保证选择组作为代价除完后自己场上仍有怪兽区域空位，并返回选中的组。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：取出目标选择阶段保存的3只「狱火机」怪兽，将它们除外，从而完成特殊召唤规则手续。
function c14799437.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3只「狱火机」怪兽以表侧表示除外，作为这次特殊召唤必须支付的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动判定与操作信息设置：检查场上是否存在除自身以外的其他怪兽，若存在则将它们全部作为破坏对象，并设置破坏的操作信息。
function c14799437.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时可发动性检查：若场上存在除自身以外的其他怪兽，则满足①效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除自身以外的所有怪兽，作为将被①效果破坏的对象集合（包含双方场上）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 将本次连锁要破坏的怪兽对象组及其数量写入操作信息，使相关卡片能正确响应破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：获取场上除自身以外的所有怪兽，并将它们全部破坏（效果破坏）。
function c14799437.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有怪兽，排除自身是为了避免破坏自己；通过aux.ExceptThisCard确保排除的是仍与效果关联的自己。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将上述所有怪兽以效果（REASON_EFFECT）破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：此卡没有被战斗破坏；且连锁中发动的效果是魔法·陷阱卡的效果；且该连锁的发动可以被无效。
function c14799437.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 追加判断：触发的效果必须是魔法·陷阱卡的类型（TYPE_SPELL+TYPE_TRAP），并且当前连锁可以被无效（IsChainNegatable）。
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 作为解放cost的过滤器：排除处于战斗破坏状态的怪兽（因为这些怪兽即将被战斗破坏，不能作为cost）。
function c14799437.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的代价处理：检查并解放自己场上1只怪兽作为发动代价，选择满足条件的怪兽后解放。
function c14799437.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1只可解放的怪兽（排除会被战斗破坏的怪兽）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c14799437.cfilter,1,nil) end
	-- 选择自己场上1只可解放的怪兽，作为发动这个效果的cost。
	local g=Duel.SelectReleaseGroup(tp,c14799437.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为发动②效果的cost。
	Duel.Release(g,REASON_COST)
end
-- ②效果处理：无效对方发动的魔法·陷阱卡，并将那张卡除外；无效成功且该卡仍与连锁相关时执行除外。
function c14799437.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断：如果该连锁发动被成功无效（Duel.NegateActivation返回true），且被无效的那张卡仍然与连锁效果关联，则进行后续除外处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效的魔法·陷阱卡以表侧表示除外（REASON_EFFECT），完成②效果的除外部分。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
