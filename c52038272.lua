--インフェルノイド・ルキフグス
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
-- ①：1回合1次，以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c52038272.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c52038272.spcon)
	e2:SetTarget(c52038272.sptg)
	e2:SetOperation(c52038272.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52038272,0))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c52038272.descost)
	e3:SetTarget(c52038272.destg)
	e3:SetOperation(c52038272.desop)
	c:RegisterEffect(e3)
	-- 对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52038272,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c52038272.rmcon)
	e4:SetCost(c52038272.rmcost)
	e4:SetTarget(c52038272.rmtg)
	e4:SetOperation(c52038272.rmop)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的「狱火机」怪兽，用于特殊召唤的条件检查。
function c52038272.spfilter(c,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确保目标怪兽所在区域有空位。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤场上表侧表示的效果怪兽，用于等级或阶级合计计算。
function c52038272.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 根据怪兽类型返回其等级或阶级值。
function c52038272.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 判断是否满足特殊召唤条件：场上的效果怪兽等级·阶级合计不超过8，并且手卡或墓地有可除外的「狱火机」怪兽。
function c52038272.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有效果怪兽的等级或阶级总和。
	local sum=Duel.GetMatchingGroup(c52038272.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c52038272.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 检查是否存在满足条件的「狱火机」怪兽用于特殊召唤。
	return Duel.IsExistingMatchingCard(c52038272.spfilter,tp,loc,0,1,c,tp)
end
-- 选择并设置要除外的「狱火机」怪兽。
function c52038272.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c52038272.spfilter,tp,loc,0,c,tp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时将选定的怪兽除外。
function c52038272.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽以特殊召唤原因除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 设置效果发动时不能攻击的限制。
function c52038272.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 设置此效果发动后本回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 设定破坏效果的目标选择逻辑。
function c52038272.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否存在可破坏的场上怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标怪兽。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果。
function c52038272.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 设定除外效果的发动条件：仅在对方回合时可发动。
function c52038272.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 设定除外效果的费用支付逻辑。
function c52038272.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择要解放的怪兽。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选定怪兽解放作为费用。
	Duel.Release(g,REASON_COST)
end
-- 设定除外效果的目标选择逻辑。
function c52038272.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标卡。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息为除外效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 执行除外效果。
function c52038272.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
