--ダイナミスト・ブラキオン
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：自己的怪兽区域没有「雾动机龙·腕龙」存在，场上的攻击力最高的怪兽在对方场上存在的场合，这张卡可以从手卡特殊召唤。
function c368382.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c368382.negcon)
	e2:SetOperation(c368382.negop)
	c:RegisterEffect(e2)
	-- ①：自己的怪兽区域没有「雾动机龙·腕龙」存在，场上的攻击力最高的怪兽在对方场上存在的场合，这张卡可以从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c368382.spcon)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标卡片是否为己方场上的「雾动机龙」怪兽
function c368382.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 判断连锁是否可以被无效的条件函数，包括是否已使用过效果、目标是否为「雾动机龙」卡、是否可无效等
function c368382.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(368382)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c368382.tfilter,1,e:GetHandler(),tp)
		-- 检查当前连锁是否可以被无效且未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 处理灵摆效果的无效操作，包括选择是否发动、注册使用标志、无效效果并破坏自身
function c368382.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动该效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(368382,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 尝试使当前连锁的效果无效
		if Duel.NegateEffect(ev) then
			-- 中断当前连锁处理，使后续效果不同时处理
			Duel.BreakEffect()
			-- 将自身破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断目标卡片是否为「雾动机龙·腕龙」
function c368382.cfilter(c)
	return c:IsFaceup() and c:IsCode(368382)
end
-- 判断是否满足特殊召唤条件，包括己方场上无腕龙、对方场上存在攻击力最高的怪兽、有空位等
function c368382.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方场上的所有表侧怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 检查己方怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在「雾动机龙·腕龙」
		and not Duel.IsExistingMatchingCard(c368382.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and tg:IsExists(Card.IsControler,1,nil,1-tp)
end
