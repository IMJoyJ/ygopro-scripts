--D-HERO ダイナマイトガイ
-- 效果：
-- ①：怪兽进行战斗的伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0，双方玩家受到1000伤害。
-- ②：把墓地的这张卡除外，以自己场上1只「命运英雄」怪兽为对象才能发动。那只怪兽的攻击力直到下次的对方回合结束时上升1000。
function c37780349.initial_effect(c)
	-- ①：怪兽进行战斗的伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0，双方玩家受到1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37780349,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c37780349.dmcon)
	e1:SetCost(c37780349.dmcost)
	e1:SetTarget(c37780349.dmtg)
	e1:SetOperation(c37780349.dmop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「命运英雄」怪兽为对象才能发动。那只怪兽的攻击力直到下次的对方回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37780349,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将此卡从手卡丢弃作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37780349.atktg)
	e2:SetOperation(c37780349.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动时的发动条件判断，判断自己是否在本次战斗中受到过伤害
function c37780349.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己是否在本次战斗中受到过伤害
	return Duel.GetBattleDamage(tp)>0
end
-- 将此卡从手卡丢弃作为cost
function c37780349.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡丢弃作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 设置效果处理时要对双方玩家造成1000伤害
function c37780349.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要对双方玩家造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 处理效果，使自己在本次战斗中不会受到战斗伤害，并给双方玩家造成1000伤害
function c37780349.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己在本次战斗中不会受到战斗伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 给与自己1000伤害
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	-- 给与对方1000伤害
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 触发伤害处理完成的时点
	Duel.RDComplete()
end
-- 用于筛选场上表侧表示的「命运英雄」怪兽
function c37780349.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 选择场上1只表侧表示的「命运英雄」怪兽作为效果对象
function c37780349.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37780349.filter(chkc) end
	-- 判断场上是否存在1只表侧表示的「命运英雄」怪兽
	if chk==0 then return Duel.IsExistingTarget(c37780349.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「命运英雄」怪兽作为效果对象
	Duel.SelectTarget(tp,c37780349.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果，使选择的怪兽攻击力上升1000
function c37780349.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使选择的怪兽攻击力上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
