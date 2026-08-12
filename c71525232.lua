--破滅竜ガンドラX
-- 效果：
-- ①：这张卡从手卡召唤·特殊召唤时才能发动。场上的其他怪兽全部破坏，给与对方破坏的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。这张卡的攻击力变成和这个效果给与对方的伤害相同数值。
-- ②：自己结束阶段发动。自己基本分变成一半。
function c71525232.initial_effect(c)
	-- ①：这张卡从手卡召唤·特殊召唤时才能发动。场上的其他怪兽全部破坏，给与对方破坏的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。这张卡的攻击力变成和这个效果给与对方的伤害相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71525232,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c71525232.condition)
	e1:SetTarget(c71525232.target)
	e1:SetOperation(c71525232.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段发动。自己基本分变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71525232,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c71525232.hvcon)
	e3:SetOperation(c71525232.hvop)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否是从手卡召唤或特殊召唤
function c71525232.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤函数：获取场上表侧表示怪兽的原本攻击力（若小于0则视为0），用于在发动时估算伤害
function c71525232.damfilter(c)
	if c:IsFaceup() then
		return math.max(c:GetTextAttack(),0)
	else return 0 end
end
-- 效果①的发动准备与效果分类声明，检查场上是否存在其他怪兽，并计算预计造成的伤害以设置伤害操作信息
function c71525232.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除这张卡以外的其他怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	local mg,atk=g:GetMaxGroup(c71525232.damfilter)
	if atk>0 then
		-- 设置伤害操作信息，给与对方相当于被破坏怪兽中最高原本攻击力数值的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
-- 过滤函数：获取被破坏怪兽的原本攻击力（若小于0则视为0），用于在效果处理时确定实际破坏怪兽中的最高原本攻击力
function c71525232.filter(c)
	return math.max(c:GetTextAttack(),0)
end
-- 效果①的效果处理：破坏场上其他怪兽，给与对方破坏怪兽中最高原本攻击力数值的伤害，并使自身攻击力变成与该伤害相同数值
function c71525232.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的所有怪兽（若这张卡已离场则获取全部怪兽）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 破坏场上的其他怪兽，并检查是否成功破坏了至少1张卡
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的怪兽卡片组
		local og=Duel.GetOperatedGroup()
		local mg,atk=og:GetMaxGroup(c71525232.filter)
		-- 给与对方相当于被破坏怪兽中最高原本攻击力数值的伤害，并记录实际受到的伤害值
		local dam=Duel.Damage(1-tp,atk,REASON_EFFECT)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的攻击力变成和这个效果给与对方的伤害相同数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(dam)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 效果②的发动条件：检查当前是否为自己的回合
function c71525232.hvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的效果处理：将自己的基本分变成一半（向上取整）
function c71525232.hvop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己的基本分变成一半（向上取整）
	Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
end
