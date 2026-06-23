--ダイナミスト・アンキロス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，自己的「雾动机龙」怪兽战斗破坏的怪兽除外。
function c32134638.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
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
	-- 设置效果目标为所有属于「雾动机龙」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd8))
	c:RegisterEffect(e2)
end
-- 用于筛选满足条件的「雾动机龙」怪兽（场上正面表示控制者为玩家的怪兽）
function c32134638.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 判断连锁是否可以被无效，且目标卡组中存在符合条件的「雾动机龙」怪兽
function c32134638.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(32134638)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c32134638.tfilter,1,e:GetHandler(),tp)
		-- 检查当前连锁是否可以被无效且未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 询问玩家是否发动效果，若发动则注册flag并尝试无效连锁效果，随后破坏自身
function c32134638.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动该效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(32134638,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 尝试使当前连锁的效果无效
		if Duel.NegateEffect(ev) then
			-- 中断当前连锁处理，防止后续效果同时处理
			Duel.BreakEffect()
			-- 将自身以效果原因破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
