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
	-- ①：这张卡特殊召唤时才能发动。「炼狱」卡以外的场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c23440231.destg)
	e3:SetOperation(c23440231.desop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，这张卡以外的怪兽的效果发动时，把自己场上1只怪兽解放才能发动。那个发动无效并除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCountLimit(1)
	e4:SetCondition(c23440231.negcon)
	e4:SetCost(c23440231.negcost)
	-- 设置效果目标为辅助函数aux.nbtg，用于处理连锁中无效化与除外操作。
	e4:SetTarget(aux.nbtg)
	e4:SetOperation(c23440231.negop)
	c:RegisterEffect(e4)
end
-- 过滤满足「狱火机」卡组、怪兽类型且可作为除外费用的卡片。
function c23440231.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤场上表侧表示的效果怪兽。
function c23440231.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 根据怪兽类型返回其等级或阶级。
function c23440231.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 检查满足条件的场上效果怪兽等级或阶级总和是否不超过8，并确认是否有3张符合条件的「狱火机」怪兽可除外。
function c23440231.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有效果怪兽并计算其等级或阶级总和。
	local sum=Duel.GetMatchingGroup(c23440231.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c23440231.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c23440231.spfilter,tp,loc,0,c)
	-- 检查是否存在3张满足条件的「狱火机」怪兽组。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 选择满足条件的3张「狱火机」怪兽组并设置为效果标签对象。
function c23440231.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c23440231.spfilter,tp,loc,0,c)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从满足条件的怪兽组中选择3张并验证其是否满足怪兽区空位要求。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将已选择的3张怪兽从游戏中除外。
function c23440231.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽组以除外形式移出游戏。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤非「炼狱」卡组且为魔法或陷阱类型的卡。
function c23440231.desfilter(c)
	return (c:IsFacedown() or not c:IsSetCard(0xc5)) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断是否存在满足条件的魔法或陷阱卡。
function c23440231.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c23440231.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取满足条件的魔法或陷阱卡组。
	local g=Duel.GetMatchingGroup(c23440231.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏满足条件的魔法或陷阱卡。
function c23440231.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的魔法或陷阱卡组。
	local g=Duel.GetMatchingGroup(c23440231.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏指定的魔法或陷阱卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 设置连锁无效的条件。
function c23440231.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:GetHandler()~=e:GetHandler()
		-- 确保连锁发动的是怪兽效果且可被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤未在战斗中被破坏的怪兽。
function c23440231.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置发动无效化效果的成本为解放1只怪兽。
function c23440231.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只符合条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c23440231.cfilter,1,nil) end
	-- 选择1只符合条件的怪兽进行解放。
	local g=Duel.SelectReleaseGroup(tp,c23440231.cfilter,1,1,nil)
	-- 以解放为代价支付成本。
	Duel.Release(g,REASON_COST)
end
-- 执行无效化连锁发动并除外相关卡。
function c23440231.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效化连锁发动且相关卡是否有效。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效化的卡以除外形式移出游戏。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
