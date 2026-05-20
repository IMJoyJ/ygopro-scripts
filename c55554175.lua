--EMクラシックリボー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：对方怪兽的直接攻击宣言时这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成1。
-- ②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己的灵摆区域放置。
-- ③：这张卡被自身的灵摆效果破坏的场合发动。战斗阶段结束。
function c55554175.initial_effect(c)
	-- 初始化灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：对方怪兽的直接攻击宣言时这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c55554175.descon)
	e1:SetOperation(c55554175.desop)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃，以自己的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成1。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55554175,0))  --"改变灵摆刻度"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,55554175)
	e2:SetCost(c55554175.sccost)
	e2:SetTarget(c55554175.sctg)
	e2:SetOperation(c55554175.scop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,55554176)
	e3:SetCondition(c55554175.pencon)
	e3:SetTarget(c55554175.pentg)
	e3:SetOperation(c55554175.penop)
	c:RegisterEffect(e3)
	-- ③：这张卡被自身的灵摆效果破坏的场合发动。战斗阶段结束。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c55554175.endcon)
	e4:SetOperation(c55554175.endop)
	c:RegisterEffect(e4)
end
-- 灵摆效果①的触发条件函数（对方怪兽直接攻击宣言时）
function c55554175.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 灵摆效果①的效果处理函数（破坏自身）
function c55554175.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 怪兽效果①的代价函数（从手卡丢弃这张卡）
function c55554175.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为丢弃代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD+REASON_COST)
end
-- 过滤当前灵摆刻度不等于1的卡片
function c55554175.scfilter(c)
	return c:GetCurrentScale()~=1
end
-- 怪兽效果①的目标选择函数（选择自己灵摆区域1张刻度不为1的卡为对象）
function c55554175.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c55554175.scfilter(chkc) end
	-- 检查自己灵摆区域是否存在至少1张刻度不为1的卡
	if chk==0 then return Duel.IsExistingTarget(c55554175.scfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己灵摆区域1张刻度不为1的卡作为效果的对象
	Duel.SelectTarget(tp,c55554175.scfilter,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 怪兽效果①的效果处理函数（将对象卡的灵摆刻度直到回合结束时变成1）
function c55554175.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那张卡的灵摆刻度直到回合结束时变成1。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
-- 怪兽效果②的触发条件函数（自己受到战斗伤害时）
function c55554175.pencon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 怪兽效果②的目标选择函数（检查灵摆区域是否有空位，并设置操作信息）
function c55554175.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 设置效果处理信息为将墓地的这张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 怪兽效果②的效果处理函数（将这张卡在自己的灵摆区域放置）
function c55554175.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 怪兽效果③的触发条件函数（这张卡被自身的效果破坏时）
function c55554175.endcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_EFFECT) and rc==c
end
-- 怪兽效果③的效果处理函数（跳过战斗阶段，即结束战斗阶段）
function c55554175.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方的战斗阶段，强制结束战斗阶段
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
