--拷問車輪
-- 效果：
-- 以对方场上1只怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽不能攻击，也不能作表示形式的变更。那只怪兽从场上离开时这张卡破坏。
-- ②：自己准备阶段发动。给与对方500伤害。这个效果在作为对象的怪兽在怪兽区域存在的场合进行发动和处理。
function c54704216.initial_effect(c)
	-- 以对方场上1只怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c54704216.target)
	e1:SetOperation(c54704216.operation)
	c:RegisterEffect(e1)
	-- 作为对象的怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e3)
	-- ②：自己准备阶段发动。给与对方500伤害。这个效果在作为对象的怪兽在怪兽区域存在的场合进行发动和处理。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54704216,0))  --"伤害"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c54704216.damcon)
	e4:SetTarget(c54704216.damtg)
	e4:SetOperation(c54704216.damop)
	c:RegisterEffect(e4)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c54704216.descon)
	e5:SetOperation(c54704216.desop)
	c:RegisterEffect(e5)
end
-- 发动时的对象选择与判定处理
function c54704216.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的一只怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只怪兽作为对象
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 发动处理，将此卡与选择的对象怪兽建立持续对象关系
function c54704216.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 检查作为对象的怪兽是否从场上离开，以触发此卡的自毁效果
function c54704216.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏此卡的处理
function c54704216.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏此卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 检查是否为自己的准备阶段，且作为对象的怪兽依然存在
function c54704216.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己，且此卡当前存在有效的对象怪兽
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFirstCardTarget()~=nil
end
-- 伤害效果的发动准备，设置伤害对象和伤害数值
function c54704216.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的参数值为500
	Duel.SetTargetParam(500)
	-- 注册连锁的操作信息，表示该效果会给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的实际处理
function c54704216.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():GetFirstCardTarget() then return end
	-- 获取当前连锁中设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
