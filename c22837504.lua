--霞の谷の戦士
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，和这张卡的战斗没被破坏的对方怪兽在伤害步骤结束时回到持有者手卡。
function c22837504.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，和这张卡的战斗没被破坏的对方怪兽在伤害步骤结束时回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22837504,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c22837504.retcon)
	e1:SetTarget(c22837504.rettg)
	e1:SetOperation(c22837504.retop)
	c:RegisterEffect(e1)
end
-- 条件函数开头：先判断这张卡是否仍与本次战斗关联（若已离场或已与本次战斗无关则效果不发动）；然后声明局部变量t，用于暂存与这张卡战斗的对方怪兽。
function c22837504.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToBattle() then return false end
	local t=nil
	-- 若事件参数ev为0，表示这张卡是攻击者，则将攻击目标（对方被攻击的怪兽）作为战斗对象t。
	if ev==0 then t=Duel.GetAttackTarget()
	-- 否则（ev不为0，表示这张卡是被攻击方），则将攻击者（对方怪兽）作为战斗对象t。
	else t=Duel.GetAttacker() end
	e:SetLabelObject(t)
	return t and t:IsRelateToBattle()
end
-- 必发诱发效果的目标函数：检查阶段直接返回true，表示效果必然发动；随后将暂存的战斗对象登记为回手牌处理对象。
function c22837504.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记连锁操作信息：本次效果涉及回手牌，对象为之前确定的那只战斗怪兽，数量为1，持有者不确定（参数填0）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,0,0)
end
-- 效果处理函数：若之前保存的怪兽仍与本次战斗关联，则将其返回持有者手牌。
function c22837504.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsRelateToBattle() then
		-- 将该怪兽返回其持有者手牌，原因标记为效果（REASON_EFFECT）。
		Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
	end
end
