--スリーストライク・バリア
-- 效果：
-- ①：对方场上的卡只有3张的场合，可以从以下效果选择1个发动。
-- ●这个回合，自己怪兽不会被战斗破坏。
-- ●这个回合，自己受到的战斗伤害变成0。
-- ●这个回合，每次自己怪兽给与对方战斗伤害，自己基本分回复那个数值。
function c95081386.initial_effect(c)
	-- ①：对方场上的卡只有3张的场合，可以从以下效果选择1个发动。●这个回合，自己怪兽不会被战斗破坏。●这个回合，自己受到的战斗伤害变成0。●这个回合，每次自己怪兽给与对方战斗伤害，自己基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c95081386.condition)
	e1:SetTarget(c95081386.target)
	e1:SetOperation(c95081386.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方场上的卡数量为3张
function c95081386.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上的卡片数量是否等于3
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==3
end
-- 效果选择与发动处理：让玩家从三个效果中选择一个，并将选择的索引保存到Label中
function c95081386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家选择其中一个效果发动
	local op=Duel.SelectOption(tp,aux.Stringid(95081386,0),aux.Stringid(95081386,1),aux.Stringid(95081386,2))  --"自己怪兽不会被战斗破坏/自己受到的战斗伤害变成0/战斗伤害时自己基本分回复"
	e:SetLabel(op)
end
-- 效果处理：根据玩家的选择，注册对应的回合内持续效果
function c95081386.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		-- ●这个回合，自己怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册“自己怪兽不会被战斗破坏”的全局效果
		Duel.RegisterEffect(e1,tp)
	elseif sel==1 then
		-- ●这个回合，自己受到的战斗伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册“自己受到的战斗伤害变成0”的全局效果
		Duel.RegisterEffect(e1,tp)
	else
		-- ●这个回合，每次自己怪兽给与对方战斗伤害，自己基本分回复那个数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DAMAGE)
		e1:SetCondition(c95081386.reccon)
		e1:SetOperation(c95081386.recop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册“给与对方战斗伤害时回复LP”的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为自己场上的怪兽给与对方战斗伤害
function c95081386.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:GetFirst():IsControler(tp)
end
-- 回复与该战斗伤害相同数值的生命值
function c95081386.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己回复与战斗伤害数值相同的生命值
	Duel.Recover(tp,ev,REASON_EFFECT)
end
