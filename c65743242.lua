--地縛霊の誘い
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。那个攻击对象由自己重新选择。
function c65743242.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。那个攻击对象由自己重新选择。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c65743242.condition)
	e1:SetTarget(c65743242.target)
	e1:SetOperation(c65743242.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方怪兽攻击宣言时
function c65743242.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 发动时的合法性检查，判断是否存在其他可重新选择的攻击对象
function c65743242.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ag,da=eg:GetFirst():GetAttackableTarget()
		-- 获取当前的攻击目标
		local at=Duel.GetAttackTarget()
		-- 判断是否存在除当前攻击目标以外的可攻击怪兽，或者当前有攻击目标且可以变更为直接攻击
		return ag:IsExists(aux.TRUE,1,at) or (at~=nil and da)
	end
end
-- 效果处理：由自己重新选择攻击对象
function c65743242.activate(e,tp,eg,ep,ev,re,r,rp)
	local ag,da=eg:GetFirst():GetAttackableTarget()
	-- 获取当前的攻击目标
	local at=Duel.GetAttackTarget()
	if da and at~=nil then
		local sel=0
		-- 提示玩家选择攻击方式
		Duel.Hint(HINT_SELECTMSG,tp,31)
		-- 判断是否存在除当前攻击目标以外的其他可攻击怪兽
		if ag:IsExists(aux.TRUE,1,at) then
			-- 让玩家选择“直接攻击”或“选择怪兽作为攻击对象”
			sel=Duel.SelectOption(tp,1213,1214)
		else
			-- 让玩家选择“直接攻击”
			sel=Duel.SelectOption(tp,1213)
		end
		if sel==0 then
			-- 将攻击对象变更为直接攻击
			Duel.ChangeAttackTarget(nil)
			return
		end
	end
	-- 提示玩家选择攻击的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)  --"请选择攻击的对象"
	local g=ag:Select(tp,1,1,at)
	local tc=g:GetFirst()
	if tc then
		-- 将攻击对象变更为选中的怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
