--白翼の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，可以把以自己场上的魔法师族·暗属性怪兽为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这张卡在规则上也当作「同调龙」卡使用。灵摆召唤的这张卡被同调召唤使用的场合除外。
function c11067666.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，可以把以自己场上的魔法师族·暗属性怪兽为对象发动的效果无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c11067666.condition)
	e1:SetOperation(c11067666.operation)
	c:RegisterEffect(e1)
	-- 这张卡在规则上也当作「同调龙」卡使用。灵摆召唤的这张卡被同调召唤使用的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c11067666.rmcon)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽（魔法师族·暗属性且在场上的怪兽）
function c11067666.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp)
end
-- 判断是否满足效果发动条件（连锁效果为目标效果且对象为魔法师族·暗属性怪兽，且该连锁可被无效）
function c11067666.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(11067666)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c11067666.cfilter,1,nil,tp)
		-- 检查当前连锁是否可以被无效且未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 处理效果发动时的操作（选择是否发动效果并执行无效和破坏）
function c11067666.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动该效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		-- 提示玩家发动了该卡的效果
		Duel.Hint(HINT_CARD,0,11067666)
		e:GetHandler():RegisterFlagEffect(11067666,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 尝试使当前连锁效果无效
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将该卡破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 判断该卡是否为灵摆召唤且因同调召唤被除外
function c11067666.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_SYNCHRO)
end
