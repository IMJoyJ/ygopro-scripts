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
	-- 设置效果目标为无效化发动的魔法或陷阱卡。
	e4:SetTarget(aux.nbtg)
	e4:SetOperation(c14799437.negop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为「狱火机」怪兽且可作为除外费用。
function c14799437.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于判断是否为场上表侧表示的效果怪兽。
function c14799437.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级值。
function c14799437.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 判断特殊召唤条件是否满足，即场上效果怪兽等级或阶级总和不超过8且手卡/墓地有3只「狱火机」怪兽可除外。
function c14799437.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有效果怪兽并计算其等级或阶级总和。
	local sum=Duel.GetMatchingGroup(c14799437.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c14799437.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c14799437.spfilter,tp,loc,0,c)
	-- 检查是否存在满足条件的3只「狱火机」怪兽组合。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 设置特殊召唤时的选择目标函数。
function c14799437.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c14799437.spfilter,tp,loc,0,c)
	-- 提示玩家选择要除外的3只「狱火机」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 从符合条件的怪兽中选择3只组成子集。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 设置特殊召唤时的操作函数。
function c14799437.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置破坏效果的目标函数。
function c14799437.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否场上存在其他怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上所有其他怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置破坏效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 设置破坏效果的操作函数。
function c14799437.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有其他怪兽（排除自身）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将场上所有其他怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 设置无效化发动效果的条件函数。
function c14799437.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断发动的是否为魔法或陷阱卡且可被无效。
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于判断是否为未被战斗破坏的怪兽。
function c14799437.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置无效化发动效果的成本函数。
function c14799437.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只未被战斗破坏的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c14799437.cfilter,1,nil) end
	-- 选择1只未被战斗破坏的怪兽进行解放。
	local g=Duel.SelectReleaseGroup(tp,c14799437.cfilter,1,1,nil)
	-- 将选中的怪兽解放作为成本。
	Duel.Release(g,REASON_COST)
end
-- 设置无效化发动效果的操作函数。
function c14799437.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效化发动效果且该效果的发动者存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效化的魔法或陷阱卡除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
