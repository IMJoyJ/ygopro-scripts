--白翼の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，可以把以自己场上的魔法师族·暗属性怪兽为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这张卡在规则上也当作「同调龙」卡使用。灵摆召唤的这张卡被同调召唤使用的场合除外。
function c11067666.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性（灵摆召唤、灵摆区发动等机制），使其可以作为灵摆卡使用。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果①：1回合1次，可以把以自己场上的魔法师族·暗属性怪兽为对象发动的效果无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c11067666.condition)
	e1:SetOperation(c11067666.operation)
	c:RegisterEffect(e1)
	-- 对应怪兽效果：灵摆召唤的这张卡被同调召唤使用的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c11067666.rmcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：用于判断连锁对象中是否存在自己场上表侧表示的魔法师族·暗属性怪兽（位于主要怪兽区且控制者为tp）。
function c11067666.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp)
end
-- 发动条件：本回合尚未使用过此效果（flag为0）；被无效的连锁效果是取对象效果；其对象中存在满足条件的自己场上的魔法师族·暗属性怪兽；且该连锁效果可以被无效且尚未被无效。
function c11067666.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁（编号ev）所对应的效果对象卡组，用于后续检查是否存在符合条件的目标。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(11067666)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c11067666.cfilter,1,nil,tp)
		-- 进一步确认该连锁效果能够被无效，并且当前没有被无效，避免对已无效的效果重复发动。
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 效果处理：询问玩家是否发动；选择发动后展示卡牌动画，记录一回合一次的使用标记，成功无效对方效果后，接着破坏这张卡。
function c11067666.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前回合玩家选择是否发动白翼之魔术师的效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		-- 向玩家展示白翼之魔术师的卡片影像，作为效果发动提示。
		Duel.Hint(HINT_CARD,0,11067666)
		e:GetHandler():RegisterFlagEffect(11067666,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 尝试无效编号为ev的连锁效果；若无效成功则返回true并继续执行后续破坏。
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，使接下来的“这张卡破坏”视为另一段处理，以符合效果原文“那之后”的先后语义，并避免时点被占用。
			Duel.BreakEffect()
			-- 以效果原因将这张卡（白翼之魔术师）自身破坏。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 除外条件：这张卡是通过灵摆召唤出场的，并且作为同调召唤的素材被使用（作为同调素材而离场），此时满足‘灵摆召唤的这张卡被同调召唤使用的场合除外’的条件。
function c11067666.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_SYNCHRO)
end
