--幻影霧剣
-- 效果：
-- 以场上1只效果怪兽为对象才能把这张卡发动。这个卡名的②的效果1回合只能使用1次。
-- ①：作为对象的怪兽不能攻击，效果无效化，双方怪兽不能选择作为对象的怪兽作为攻击对象。那只怪兽从场上离开时这张卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c25542642.initial_effect(c)
	-- ①：作为对象的怪兽不能攻击，效果无效化，双方怪兽不能选择作为对象的怪兽作为攻击对象。那只怪兽从场上离开时这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c25542642.target)
	e1:SetOperation(c25542642.tgop)
	c:RegisterEffect(e1)
	-- ①：作为对象的怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e5)
	-- ①：双方怪兽不能选择作为对象的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetValue(c25542642.tgval)
	c:RegisterEffect(e4)
	-- ①：那只怪兽从场上离开时这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(c25542642.descon)
	e6:SetOperation(c25542642.desop)
	c:RegisterEffect(e6)
	-- ②：把墓地的这张卡除外，以自己墓地1只「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(25542642,0))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCountLimit(1,25542642)
	-- 将此卡除外作为cost
	e7:SetCost(aux.bfgcost)
	e7:SetTarget(c25542642.sptg)
	e7:SetOperation(c25542642.spop)
	c:RegisterEffect(e7)
end
-- 判断场上是否存在表侧表示的效果怪兽
function c25542642.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 选择场上1只表侧表示的效果怪兽作为对象
function c25542642.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25542642.filter(chkc) end
	-- 判断场上是否存在1只表侧表示的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c25542642.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的效果怪兽作为对象
	local g=Duel.SelectTarget(tp,c25542642.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为使对象怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 设置对象怪兽为效果对象
function c25542642.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断目标怪兽是否为效果对象
function c25542642.tgval(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
-- 判断对象怪兽是否离开场上
function c25542642.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽离开场上时将此卡破坏
function c25542642.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断墓地是否存在「幻影骑士团」怪兽
function c25542642.spfilter(c,e,tp)
	return c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择墓地1只「幻影骑士团」怪兽作为对象
function c25542642.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c25542642.spfilter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在「幻影骑士团」怪兽
		and Duel.IsExistingTarget(c25542642.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只「幻影骑士团」怪兽作为对象
	local g=Duel.SelectTarget(tp,c25542642.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤对象怪兽
function c25542642.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有特殊召唤怪兽的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 特殊召唤对象怪兽并设置其离场时除外效果
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置特殊召唤的怪兽离场时除外的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
