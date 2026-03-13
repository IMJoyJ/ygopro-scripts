--エレキー
-- 效果：
-- 自己场上表侧表示存在的名字带有「电气」的怪兽在这个回合可以直接攻击对方玩家。
function c53193261.initial_effect(c)
	-- 效果原文：自己场上表侧表示存在的名字带有「电气」的怪兽在这个回合可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c53193261.target)
	e1:SetOperation(c53193261.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查一张卡是否为表侧表示且名字带有「电气」
function c53193261.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe)
end
-- 判定函数：检查是否存在满足条件的怪兽
function c53193261.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查阶段未通过，则返回是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53193261.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 发动函数：获取所有满足条件的怪兽并为它们设置直接攻击效果
function c53193261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c53193261.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将直接攻击效果注册给目标怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
