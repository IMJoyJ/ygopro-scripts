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
	-- 设置效果的发动条件：伤害步骤以外才能发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c99913726.atkcost)
	e2:SetTarget(c99913726.atktg)
	e2:SetOperation(c99913726.atkop)
	c:RegisterEffect(e2)
end
c99913726.mentioned_counter={
	[0x1041]=true,
}
-- 过滤条件：放置有捕食指示物、可以为了特殊召唤被解放，且该怪兽离开后自己场上有怪兽区域空位的怪兽
function c99913726.rfilter(c,tp)
	return c:GetCounter(0x1041)>0 and c:IsReleasable(REASON_SPSUMMON)
		-- 并且该怪兽离开后自己场上必须有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 检查这张卡是否可以被特殊召唤，以及双方场上是否存在满足解放条件的怪兽
function c99913726.hspcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查双方场上是否存在至少1只满足解放条件的怪兽
	return Duel.IsExistingMatchingCard(c99913726.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
end
-- 让玩家选择1只满足条件的怪兽作为解放的对象，为特殊召唤作准备
function c99913726.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取双方场上所有满足解放条件的怪兽集合
	local g=Duel.GetMatchingGroup(c99913726.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤手续：将之前选定的怪兽解放
function c99913726.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因将选定的怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤条件：可以作为代价除外的「捕食植物」怪兽
function c99913726.cfilter(c)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 从自己墓地把这张卡以外的1只「捕食植物」怪兽除外作为发动的代价
function c99913726.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以除外的此卡以外的「捕食植物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c99913726.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的此卡以外的怪兽
	local g=Duel.SelectMatchingCard(tp,c99913726.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查场上是否存在可以作为对象的表侧表示怪兽，并让玩家选择1只对象怪兽
function c99913726.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上选择1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 获取对象怪兽并让其攻击力下降500
function c99913726.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
