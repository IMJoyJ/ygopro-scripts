--霞の谷の戦士
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，和这张卡的战斗没被破坏的对方怪兽在伤害步骤结束时回到持有者手卡。
function c22837504.initial_effect(c)
	-- 效果原文内容：只要这张卡在自己场上表侧表示存在，和这张卡的战斗没被破坏的对方怪兽在伤害步骤结束时回到持有者手卡。
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
-- 效果作用：检查当前卡是否参与了战斗，若未参与则效果不发动
function c22837504.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToBattle() then return false end
	local t=nil
	-- 效果作用：若战斗为攻击方，则获取攻击目标怪兽
	if ev==0 then t=Duel.GetAttackTarget()
	-- 效果作用：若战斗为防守方，则获取攻击怪兽
	else t=Duel.GetAttacker() end
	e:SetLabelObject(t)
	return t and t:IsRelateToBattle()
end
-- 效果作用：设置连锁操作信息，指定将目标怪兽送回手牌
function c22837504.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置操作信息，指定目标为已记录的怪兽，数量为1，送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,0,0)
end
-- 效果作用：执行将符合条件的怪兽送回手牌的操作
function c22837504.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsRelateToBattle() then
		-- 效果作用：将指定怪兽以效果原因送回持有者手牌
		Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
	end
end
