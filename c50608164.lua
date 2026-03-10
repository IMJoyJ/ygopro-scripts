--M・HERO 光牙
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡的攻击力上升对方场上的怪兽数量×500。
-- ②：1回合1次，把自己墓地1只「英雄」怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降因为这个效果发动而除外的怪兽的攻击力数值。这个效果在对方回合也能发动。
function c50608164.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡的特殊召唤条件为必须通过「假面变化」进行
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升对方场上的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c50608164.val)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己墓地1只「英雄」怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降因为这个效果发动而除外的怪兽的攻击力数值。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50608164,0))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	-- 限制此效果只能在伤害步骤前发动
	e3:SetCondition(aux.dscon)
	e3:SetCost(c50608164.cost)
	e3:SetTarget(c50608164.target)
	e3:SetOperation(c50608164.operation)
	c:RegisterEffect(e3)
end
-- 计算并返回当前玩家对方场上的怪兽数量乘以500作为攻击力加成
function c50608164.val(e,c)
	-- 获取对方场上怪兽数量并乘以500作为攻击力加成数值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*500
end
-- 过滤满足条件的墓地「英雄」怪兽用于除外作为代价
function c50608164.cfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的墓地「英雄」怪兽可除外，并选择一张进行除外操作
function c50608164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足除外一张「英雄」怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c50608164.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择一张符合条件的「英雄」怪兽除外
	local g=Duel.SelectMatchingCard(tp,c50608164.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的「英雄」怪兽从游戏中除外并作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标选择条件，需选择场上一张表侧表示的怪兽
function c50608164.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检测是否满足选择一张场上表侧表示怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要攻击下降的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张场上表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽的攻击力在回合结束前下降因除外怪兽而获得的数值
function c50608164.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为选中的目标怪兽创建一个攻击力减少的效果，在回合结束时消失
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
