--ダイナミスト・プレシオス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降自己场上的「雾动机龙」卡数量×100。
function c38988538.initial_effect(c)
	-- 为这张卡附加灵摆怪兽属性，使其拥有灵摆召唤和作为灵摆卡发动的能力。
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c38988538.negcon)
	e2:SetOperation(c38988538.negop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降自己场上的「雾动机龙」卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c38988538.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 定义筛选条件：满足表侧表示、属于「雾动机龙」系列、由tp控制且在场上的卡，用于判定是否有符合条件的对象。
function c38988538.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 判定灵摆效果能否发动：该卡本回合尚未用此效果、连锁效果为取对象效果、对象中存在符合条件的「雾动机龙」卡、且该连锁效果可以被无效并尚未被无效。
function c38988538.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组，用于检查是否有「雾动机龙」卡成为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(38988538)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c38988538.tfilter,1,e:GetHandler(),tp)
		-- 确认该连锁效果可以被无效且尚未被无效，保证发动条件成立。
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 效果处理：询问玩家是否发动，若选择发动则标记本回合已使用，无效对方连锁，随后破坏自身。
function c38988538.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问控制者是否发动此效果，选择“是”才继续处理。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(38988538,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 尝试无效对方连锁的效果，若成功则进行后续破坏自身处理。
		if Duel.NegateEffect(ev) then
			-- 中断当前连锁处理，使无效效果与之后的破坏处理视为不同时进行，避免错过时点。
			Duel.BreakEffect()
			-- 将这张灵摆区域的卡以效果破坏送去墓地。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 定义筛选条件：卡为表侧表示且属于「雾动机龙」系列，用于统计自己场上的该类卡数量。
function c38988538.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd8)
end
-- 计算攻击力/守备力的变化值：统计自己场上表侧表示「雾动机龙」卡的数量，乘以-100作为下降数值。
function c38988538.atkval(e,c)
	-- 返回自己场上「雾动机龙」卡数量×100的负值，使对方怪兽攻击力·守备力下降对应数值。
	return Duel.GetMatchingGroupCount(c38988538.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-100
end
