--ぶつかり合う魂
-- 效果：
-- ①：自己的攻击表示怪兽和持有比自身的攻击力高的攻击力的对方的攻击表示怪兽进行战斗的伤害计算时才能发动。那些进行战斗的怪兽之内攻击力低的怪兽的控制者可以支付500基本分让那只怪兽的攻击力只在伤害计算时上升500。那之后，直到变成双方不支付基本分为止让这个效果重复。那次战斗发生的双方的战斗伤害变成0，伤害计算后那次战斗让怪兽被破坏的玩家的场上的卡全部送去墓地。
function c57496978.initial_effect(c)
	-- ①：自己的攻击表示怪兽和持有比自身的攻击力高的攻击力的对方的攻击表示怪兽进行战斗的伤害计算时才能发动。那些进行战斗的怪兽之内攻击力低的怪兽的控制者可以支付500基本分让那只怪兽的攻击力只在伤害计算时上升500。那之后，直到变成双方不支付基本分为止让这个效果重复。那次战斗发生的双方的战斗伤害变成0，伤害计算后那次战斗让怪兽被破坏的玩家的场上的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c57496978.condition)
	e1:SetOperation(c57496978.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件：自己的攻击表示怪兽与攻击力更高的对方攻击表示怪兽进行战斗的伤害计算时
function c57496978.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击目标（被攻击怪兽）
	local d=Duel.GetAttackTarget()
	-- 若攻击怪兽是对方的，则交换变量，确保a代表己方怪兽，d代表对方怪兽
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() d=Duel.GetAttacker() end
	return a and d and a:IsAttackPos() and d:IsAttackPos() and a:GetAttack()<d:GetAttack()
end
-- 执行卡片发动时的效果处理：循环让攻击力低的玩家选择是否支付500基本分提升500攻击力，并使战斗伤害变为0，在伤害计算后将怪兽被破坏玩家场上的卡全部送去墓地
function c57496978.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取进行战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		local g=Group.FromCards(a,d)
		local chk=true
		while chk do
			local tg=g:GetMinGroup(Card.GetAttack)
			local tc=tg:GetFirst()
			-- 检查进行战斗的怪兽中是否存在唯一的攻击力最低的怪兽，且其控制者是否能支付500基本分
			if tg:GetCount()==1 and Duel.CheckLPCost(tc:GetControler(),500)
				-- 询问攻击力较低怪兽的控制者是否选择支付500基本分
				and Duel.SelectYesNo(tc:GetControler(),aux.Stringid(57496978,0)) then  --"是否支付基本分？"
				-- 让该怪兽的控制者支付500基本分
				Duel.PayLPCost(tc:GetControler(),500)
				-- 让那只怪兽的攻击力只在伤害计算时上升500
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(500)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
				tg:GetFirst():RegisterEffect(e1)
			else
				chk=false
			end
		end
		g:KeepAlive()
		-- 那次战斗发生的双方的战斗伤害变成0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册使双方战斗伤害变成0的全局效果
		Duel.RegisterEffect(e2,tp)
		-- 伤害计算后那次战斗让怪兽被破坏的玩家的场上的卡全部送去墓地。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLED)
		e3:SetLabelObject(g)
		e3:SetOperation(c57496978.tgop)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册在伤害计算后触发的延迟效果，用于处理怪兽被破坏玩家的场上卡片送去墓地
		Duel.RegisterEffect(e3,tp)
	end
end
-- 伤害计算后，检查是否有怪兽被战斗破坏，并将被破坏怪兽控制者场上的卡全部送去墓地
function c57496978.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(Card.IsStatus,nil,STATUS_BATTLE_DESTROYED)
	local tg=Group.CreateGroup()
	if g:IsExists(Card.IsControler,1,nil,tp) then
		-- 获取自己场上的所有卡片
		local g1=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
		tg:Merge(g1)
	end
	if g:IsExists(Card.IsControler,1,nil,1-tp) then
		-- 获取对方场上的所有卡片
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		tg:Merge(g2)
	end
	if tg:GetCount()>0 then
		-- 将目标卡片组以效果原因送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
