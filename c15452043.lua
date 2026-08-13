--EMソード・フィッシュ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合发动。对方场上的全部怪兽的攻击力·守备力下降600。
-- ②：这张卡在怪兽区域存在，自己对怪兽的特殊召唤成功的场合发动。对方场上的全部怪兽的攻击力·守备力下降600。
function c15452043.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。对方场上的全部怪兽的攻击力·守备力下降600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15452043,0))  --"攻守变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c15452043.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在怪兽区域存在，自己对怪兽的特殊召唤成功的场合发动。对方场上的全部怪兽的攻击力·守备力下降600。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15452043,1))  --"攻守变化"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c15452043.condition)
	e3:SetOperation(c15452043.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断特殊召唤成功的怪兽是否由己方玩家tp特殊召唤，用于确认“自己对怪兽的特殊召唤成功”这一条件。
function c15452043.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽集合中不包含本卡（避免与①重复处理本卡自身特殊召唤），且存在至少1只由自己特殊召唤的怪兽。
function c15452043.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c15452043.cfilter,1,nil,tp)
end
-- 效果处理：选取对方场上的全部表侧表示怪兽，逐只使其攻击力·守备力下降600，该变化持续到怪兽离场等标准重置时。
function c15452043.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的全部表侧表示怪兽（对方怪兽区域）作为效果处理的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力下降600（对应“攻击力·守备力下降600”中的攻击力部分，守备力下降由后续克隆效果处理）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
