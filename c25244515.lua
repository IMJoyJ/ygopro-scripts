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
-- 判断是否处于伤害步骤且尚未计算战斗伤害，同时确认攻击怪兽是否为妖仙兽且参与战斗。
function c25244515.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或伤害已计算，则效果不满足发动条件
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是自己控制，则获取防守怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	-- 返回是否满足发动条件：攻击怪兽为妖仙兽、参与战斗、且存在防守怪兽
	return tc and tc:IsSetCard(0xb3) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- 支付效果代价：将此卡从手牌丢弃至墓地
function c25244515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手牌丢弃至墓地作为效果的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 使目标怪兽的攻击力上升1000点，持续到回合结束
function c25244515.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		-- 使目标怪兽的攻击力上升1000点，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 筛选场上表侧表示的妖仙兽怪兽
function c25244515.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 选择场上一只表侧表示的妖仙兽怪兽作为效果对象
function c25244515.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25244515.filter(chkc) end
	-- 检测是否存在符合条件的妖仙兽怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c25244515.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只表侧表示的妖仙兽怪兽作为效果对象
	Duel.SelectTarget(tp,c25244515.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 使目标怪兽的攻击力上升1000点，持续到回合结束
function c25244515.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的攻击力上升1000点，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 在召唤成功后注册结束阶段触发效果
function c25244515.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在结束阶段发动，使此卡返回手牌
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
-- 设置效果操作信息，准备将此卡送回手牌
function c25244515.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将此卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行将此卡送回手牌的操作
function c25244515.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送回持有者手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
