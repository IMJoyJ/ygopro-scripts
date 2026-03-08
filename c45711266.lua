--ジュラック・プティラ
-- 效果：
-- 这张卡被攻击的场合，伤害计算后攻击怪兽回到手卡。这张卡的守备力上升这个效果回到手卡的怪兽等级×100的数值。
function c45711266.initial_effect(c)
	-- 效果原文：这张卡被攻击的场合，伤害计算后攻击怪兽回到手卡。这张卡的守备力上升这个效果回到手卡的怪兽等级×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45711266,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c45711266.condition)
	e1:SetTarget(c45711266.target)
	e1:SetOperation(c45711266.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为攻击对象
function c45711266.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：这张卡被攻击的场合，伤害计算后攻击怪兽回到手卡。
	return e:GetHandler()==Duel.GetAttackTarget()
end
-- 效果作用：设置连锁操作信息，确定将攻击怪兽送回手牌
function c45711266.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 效果作用：设置将攻击怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 效果作用：处理攻击怪兽送回手牌并根据其等级提升自身守备力
function c45711266.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() then
		local lv=tc:GetLevel()
		-- 效果作用：将攻击怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		if not c:IsStatus(STATUS_BATTLE_DESTROYED) then
			-- 效果原文：这张卡的守备力上升这个效果回到手卡的怪兽等级×100的数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(lv*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
