--伝説の柔術家
-- 效果：
-- 与守备表示的这张卡进行战斗的怪兽在伤害步骤终了时弹回其持有者的卡组的最上面。
function c25773409.initial_effect(c)
	-- 与守备表示的这张卡进行战斗的怪兽在伤害步骤终了时弹回其持有者的卡组的最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25773409,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c25773409.condition)
	e1:SetTarget(c25773409.target)
	e1:SetOperation(c25773409.operation)
	c:RegisterEffect(e1)
end
-- 伤害步骤结束时，若本卡仍与本次战斗相关、是攻击对象，且战斗发生前为守备表示，则满足诱发条件。
function c25773409.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 调用辅助函数确认伤害步骤结束时本卡与战斗相关（未离场或处于战斗破坏状态），且本次战斗的攻击对象正是本卡。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttackTarget()==e:GetHandler()
		and bit.band(e:GetHandler():GetBattlePosition(),POS_DEFENSE)~=0
end
-- 发动时的合法性检查通过，并登记将攻击怪兽弹回卡组的操作信息；该效果不取对象，处理时直接使用攻击怪兽。
function c25773409.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记效果操作信息：本效果将把1只攻击怪兽弹回持有者卡组，分类为回卡组，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.GetAttacker(),1,0,0)
end
-- 效果处理：取得攻击怪兽，若它仍与本次战斗关联，则将其弹回持有者卡组的最上面。
function c25773409.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽，作为将要弹回卡组的对象。
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 将攻击怪兽以效果原因送回其持有者的卡组最顶端（SEQ_DECKTOP），即弹回卡组最上面。
	Duel.SendtoDeck(a,nil,SEQ_DECKTOP,REASON_EFFECT)
end
