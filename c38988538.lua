--ダイナミスト・プレシオス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降自己场上的「雾动机龙」卡数量×100。
function c38988538.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 过滤函数，用于判断目标卡片是否为己方场上表侧表示的「雾动机龙」卡
function c38988538.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 连锁无效效果的发动条件函数，判断是否满足无效条件
function c38988538.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(38988538)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c38988538.tfilter,1,e:GetHandler(),tp)
		-- 判断当前连锁是否可以被无效且未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 连锁无效效果的处理函数，用于选择是否发动无效效果并执行破坏
function c38988538.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动该效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(38988538,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 使当前连锁的效果无效
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，防止后续效果同时处理
			Duel.BreakEffect()
			-- 将该卡破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断目标卡片是否为「雾动机龙」卡
function c38988538.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd8)
end
-- 攻击力下降值计算函数，根据己方场上「雾动机龙」卡数量计算攻击力下降值
function c38988538.atkval(e,c)
	-- 返回己方场上「雾动机龙」卡的数量乘以-100作为攻击力下降值
	return Duel.GetMatchingGroupCount(c38988538.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-100
end
