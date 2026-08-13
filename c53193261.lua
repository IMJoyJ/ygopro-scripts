--エレキー
-- 效果：
-- 自己场上表侧表示存在的名字带有「电气」的怪兽在这个回合可以直接攻击对方玩家。
function c53193261.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「电气」的怪兽在这个回合可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c53193261.target)
	e1:SetOperation(c53193261.activate)
	c:RegisterEffect(e1)
end
-- 该函数作为过滤条件，判断怪兽是否表侧表示且名字带有「电气」字段，用于筛选出效果适用的对象。
function c53193261.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe)
end
-- 该函数为效果发动前的合法性判定，仅在己方主要怪兽区存在至少1只表侧表示且名字带有「电气」的怪兽时，效果才允许发动。
function c53193261.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 进行发动合法性检查（chk==0）时，确认场上是否存在至少1只满足条件的「电气」怪兽，存在则返回true。
	if chk==0 then return Duel.IsExistingMatchingCard(c53193261.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理时，获取己方场上所有表侧表示且名字带有「电气」的怪兽，逐一赋予其在这个回合可以直接攻击对方玩家的效果。
function c53193261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区中所有表侧表示且名字带有「电气」的怪兽，组成一个卡片集合g。
	local g=Duel.GetMatchingGroup(c53193261.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 在这个回合可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
