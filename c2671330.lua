--ハイパーハンマーヘッド
-- 效果：
-- 与这张卡进行战斗且未被破坏的对方怪兽，在伤害步骤终了时弹回其持有者手卡。
function c2671330.initial_effect(c)
	-- 与这张卡进行战斗且未被破坏的对方怪兽，在伤害步骤终了时弹回其持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2671330,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c2671330.retcon)
	e1:SetTarget(c2671330.rettg)
	e1:SetOperation(c2671330.retop)
	c:RegisterEffect(e1)
end
-- 条件函数：获取与这张卡战斗的对方怪兽并暂存到LabelObject，同时确认本卡仍与战斗相关、对方怪兽仍与本次战斗关联，且处于伤害步骤结束时。
function c2671330.retcon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 返回条件：伤害步骤结束且本卡未离场或处于战斗破坏状态，存在战斗对象，且该战斗对象仍与本次战斗关联。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRelateToBattle()
end
-- 发动时的目标函数：本效果发动时无需额外选择目标，直接允许发动；同时将操作信息设定为把暂存的战斗对象弹回手牌。
function c2671330.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：类别为回手牌，处理对象为条件中暂存的战斗对象，数量为1，不指定持有者和位置。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,0,0)
end
-- 效果处理函数：若暂存的战斗对象仍与本次战斗关联，则将其弹回持有者手卡。
function c2671330.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsRelateToBattle() then
		-- 将暂存的战斗对象送回其持有者手卡，原因记为效果原因。
		Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
	end
end
