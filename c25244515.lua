--妖仙獣 辻斬風
-- 效果：
-- 「妖仙兽 辻斩风」的①②的效果1回合各能使用1次。
-- ①：自己的「妖仙兽」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡丢弃才能发动。那只自己怪兽的攻击力直到回合结束时上升1000。
-- ②：以场上1只「妖仙兽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c25244515.initial_effect(c)
	-- ①：自己的「妖仙兽」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡丢弃才能发动。那只自己怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,25244515)
	e1:SetCondition(c25244515.condition)
	e1:SetCost(c25244515.cost)
	e1:SetOperation(c25244515.operation)
	c:RegisterEffect(e1)
	-- ②：以场上1只「妖仙兽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,25244516)
	e2:SetTarget(c25244515.atktg)
	e2:SetOperation(c25244515.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c25244515.regop)
	c:RegisterEffect(e3)
end
-- 判定①的发动条件：当前必须在伤害步骤且尚未计算伤害，存在我方「妖仙兽」怪兽与对方怪兽的战斗；将我方那只「妖仙兽」怪兽存入效果标签。
function c25244515.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害阶段。
	local phase=Duel.GetCurrentPhase()
	-- 如果不是伤害阶段，或已经进行过伤害计算，则不满足①的发动时机（只能在伤害步骤开始到伤害计算前发动）。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 取得当前进行战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是对方控制的，则把判定对象改为攻击目标，即我方参与战斗的怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	-- 确认该怪兽仍参与战斗、是「妖仙兽」怪兽，并且存在对战中的攻击目标，满足①的全部发动条件。
	return tc and tc:IsSetCard(0xb3) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- ①的代价：检查这张卡是否可以从手卡丢弃，并将丢弃作为发动代价。
function c25244515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送去墓地，作为发动①的丢弃代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①的效果处理：给记录的己方「妖仙兽」怪兽附加攻击力上升1000的效果，持续到回合结束。
function c25244515.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只自己怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②的对象过滤：选择表侧表示且为「妖仙兽」怪兽的卡。
function c25244515.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- ②的发动目标处理：从双方场上选择1只表侧表示「妖仙兽」怪兽作为对象。
function c25244515.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25244515.filter(chkc) end
	-- 发动时检查双方场上是否存在至少1只表侧表示的「妖仙兽」怪兽，以判断是否可以发动。
	if chk==0 then return Duel.IsExistingTarget(c25244515.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示「妖仙兽」怪兽，并登记为效果对象。
	Duel.SelectTarget(tp,c25244515.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②的效果处理：若对象仍然合法，则赋予其攻击力上升1000的效果，直到回合结束。
function c25244515.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 召唤成功时触发：为这张卡注册一个结束阶段回手的效果，且该注册效果不会被无效。
function c25244515.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c25244515.rettg)
	e1:SetOperation(c25244515.retop)
	e1:SetReset(RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ③回手效果的发动条件：必发效果，满足条件即可发动，并登记回手操作信息。
function c25244515.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次效果为“将这张卡加入手卡”的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③的效果处理：若这张卡仍与效果相关，则将其返回持有者手卡。
function c25244515.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
