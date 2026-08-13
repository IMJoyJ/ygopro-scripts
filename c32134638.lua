--ダイナミスト・アンキロス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，自己的「雾动机龙」怪兽战斗破坏的怪兽除外。
function c32134638.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性（灵摆召唤、灵摆卡的发动等基础属性），使其可以作为灵摆卡在灵摆区域存在。
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32134638,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c32134638.negcon)
	e1:SetOperation(c32134638.negop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己的「雾动机龙」怪兽战斗破坏的怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(LOCATION_REMOVED)
	-- 设置该效果影响的对象筛选函数：仅对卡名含有「雾动机龙」字段的卡生效（因为此效果只影响自己的「雾动机龙」怪兽）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd8))
	c:RegisterEffect(e2)
end
-- 定义筛选条件：对象必须是表侧表示、卡名含有「雾动机龙」字段、由本方控制且在场上，用于检查连锁对象中是否存在可被无效的「雾动机龙」卡（并排除本卡自身）。
function c32134638.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 该效果的发动条件：本卡在灵摆区域、本回合尚未使用过此效果、对方连锁的效果是取对象效果、连锁对象中存在符合tfilter条件的我方「雾动机龙」卡、且该连锁效果可以被无效且尚未被无效。
function c32134638.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的卡片组，用于后续判断对象中是否包含符合条件的「雾动机龙」卡。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(32134638)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c32134638.tfilter,1,e:GetHandler(),tp)
		-- 追加判断当前连锁的效果能否被无效、且尚未被无效，避免对不能被无效或已经无效的效果发动。
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 该效果处理时的操作：询问玩家是否发动；若选择发动，则为本卡设置一次使用标记；若成功无效对方连锁效果，则中断当前连锁处理并破坏本卡。
function c32134638.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 让效果持有者选择是否发动此效果，因为该效果是在连锁处理时发动的诱发即时效果，需要玩家确认是否发动。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(32134638,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 尝试无效当前连锁的效果，并判断无效操作是否成功，只有成功时才继续后续的破坏处理。
		if Duel.NegateEffect(ev) then
			-- 中断当前效果的处理，使后续的破坏被视为不同时处理，满足“那之后，这张卡破坏”的先后顺序。
			Duel.BreakEffect()
			-- 以效果原因将本卡（灵摆区域的这张「雾动机龙·甲龙」）破坏。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
