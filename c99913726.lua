--捕食植物ドロソフィルム・ヒドラ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡把自己或者对方场上1只有捕食指示物放置的怪兽解放的场合可以从手卡·墓地特殊召唤。
-- ②：这张卡在场上·墓地存在的场合，把这张卡以外的自己墓地1只「捕食植物」怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。这个效果在对方回合也能发动。
function c99913726.initial_effect(c)
	-- ①：这张卡把自己或者对方场上1只有捕食指示物放置的怪兽解放的场合可以从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,99913726+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c99913726.hspcon)
	e1:SetTarget(c99913726.hsptg)
	e1:SetOperation(c99913726.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡在场上·墓地存在的场合，把这张卡以外的自己墓地1只「捕食植物」怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99913726,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,99913727)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制此效果只能在伤害步骤前发动。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c99913726.atkcost)
	e2:SetTarget(c99913726.atktg)
	e2:SetOperation(c99913726.atkop)
	c:RegisterEffect(e2)
end
c99913726.mentioned_counter={
	[0x1041]=true,
}
-- 过滤函数，用于筛选场上存在捕食指示物且可被解放的怪兽，并确保其所在玩家场上还有可用怪兽区。
function c99913726.rfilter(c,tp)
	return c:GetCounter(0x1041)>0 and c:IsReleasable(REASON_SPSUMMON)
		-- 确保目标怪兽所在玩家场上还有可用怪兽区。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足：场上是否存在带有捕食指示物且可被解放的怪兽。
function c99913726.hspcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的怪兽。
	return Duel.IsExistingMatchingCard(c99913726.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
end
-- 选择并标记要解放的怪兽，为后续特殊召唤做准备。
function c99913726.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的怪兽组合作为选择目标。
	local g=Duel.GetMatchingGroup(c99913726.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作，将指定怪兽从场上解放。
function c99913726.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际执行解放操作。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数，用于筛选墓地中可作为cost除外的「捕食植物」怪兽。
function c99913726.cfilter(c)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 支付效果cost，从墓地选择一张「捕食植物」怪兽除外。
function c99913726.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外cost的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c99913726.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张符合条件的卡作为cost除外。
	local g=Duel.SelectMatchingCard(tp,c99913726.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 实际执行将卡除外的操作。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果目标，选择场上一只表侧表示怪兽。
function c99913726.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在可作为目标的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要攻击下降的目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行效果，使目标怪兽攻击力下降500。
function c99913726.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽添加攻击力下降500的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
