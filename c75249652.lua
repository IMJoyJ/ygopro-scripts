--業炎のバリア －ファイヤー・フォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏，自己受到这个效果破坏的怪兽的原本攻击力合计数值一半的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
function c75249652.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏，自己受到这个效果破坏的怪兽的原本攻击力合计数值一半的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c75249652.condition)
	e1:SetTarget(c75249652.target)
	e1:SetOperation(c75249652.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件是否为对方怪兽的攻击宣言。
function c75249652.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 过滤出攻击表示的怪兽。
function c75249652.filter(c)
	return c:IsAttackPos()
end
-- 定义效果发动的靶向检测与操作信息注册。
function c75249652.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查对方场上是否存在至少1只攻击表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c75249652.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的攻击表示怪兽。
	local g=Duel.GetMatchingGroup(c75249652.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏对方场上的所有攻击表示怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：双方玩家将受到伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 定义效果发动后的具体处理逻辑。
function c75249652.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上所有的攻击表示怪兽。
	local g=Duel.GetMatchingGroup(c75249652.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 破坏对方场上所有的攻击表示怪兽。
		Duel.Destroy(g,REASON_EFFECT)
		-- 获取本次操作中实际被破坏的怪兽卡片组，用于后续计算原本攻击力。
		local dg=Duel.GetOperatedGroup()
		local tc=dg:GetFirst()
		local atk=0
		while tc do
			local tatk=tc:GetTextAttack()
			if tatk>0 then atk=atk+tatk end
			tc=dg:GetNext()
		end
		-- 自己受到被破坏怪兽原本攻击力合计数值一半的伤害，并记录实际受到的伤害值。
		local dam=Duel.Damage(tp,math.floor(atk/2),REASON_EFFECT)
		-- 检查自己的基本分是否大于0且实际受到了伤害，若满足则继续处理后续效果。
		if Duel.GetLP(tp)>0 and dam>0 then
			-- 中断效果处理，使后续给与对方伤害的处理与自己受到伤害的处理不视为同时发生。
			Duel.BreakEffect()
			-- 给与对方和自己受到的伤害相同数值的伤害。
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
