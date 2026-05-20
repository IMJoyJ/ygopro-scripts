--幻影剣
-- 效果：
-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。「幻影剑」的②的效果1回合只能使用1次。
-- ①：作为对象的怪兽的攻击力上升800，被战斗·效果破坏的场合，可以作为代替把这张卡破坏。那只怪兽从场上离开时这张卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c61936647.initial_effect(c)
	-- 以场上1只表侧表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c61936647.target)
	e1:SetOperation(c61936647.tgop)
	c:RegisterEffect(e1)
	-- ①：作为对象的怪兽的攻击力上升800
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- 被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c61936647.reptg)
	e4:SetValue(c61936647.repval)
	e4:SetOperation(c61936647.repop)
	c:RegisterEffect(e4)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c61936647.descon)
	e5:SetOperation(c61936647.desop)
	c:RegisterEffect(e5)
	-- ②：把墓地的这张卡除外，以自己墓地1只「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(61936647,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,61936647)
	-- 设置发动代价为把墓地的这张卡除外
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(c61936647.sptg)
	e6:SetOperation(c61936647.spop)
	c:RegisterEffect(e6)
end
-- 效果①（卡片发动）的对象选择与发动准备函数
function c61936647.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①（卡片发动）的效果处理函数
function c61936647.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 过滤作为此卡对象且因战斗或效果将被破坏的怪兽
function c61936647.repfilter(c,e)
	return e:GetHandler():IsHasCardTarget(c) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的条件检查函数
function c61936647.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c61936647.repfilter,1,nil,e) end
	-- 询问玩家是否适用代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定被破坏的怪兽是否是此卡的对象
function c61936647.repval(e,c)
	return c61936647.repfilter(c,e)
end
-- 代替破坏效果的处理函数
function c61936647.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡自身破坏作为代替
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 检查作为对象的怪兽是否离场，以确定是否触发此卡的自毁效果
function c61936647.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽离场时，将这张卡破坏的效果处理函数
function c61936647.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤自己墓地可以特殊召唤的「幻影骑士团」怪兽
function c61936647.spfilter(c,e,tp)
	return c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（墓地特召）的对象选择与发动准备函数
function c61936647.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c61936647.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为对象的「幻影骑士团」怪兽
		and Duel.IsExistingTarget(c61936647.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「幻影骑士团」怪兽作为对象
	local g=Duel.SelectTarget(tp,c61936647.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（墓地特召）的效果处理函数
function c61936647.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否已满
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的墓地怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
