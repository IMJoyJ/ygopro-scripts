--ホワイト・ホール
-- 效果：
-- 对方把「黑洞」发动时才能发动。自己场上存在的怪兽不会被那张「黑洞」的效果破坏。
function c43487744.initial_effect(c)
	-- 对方把「黑洞」发动时才能发动。自己场上存在的怪兽不会被那张「黑洞」的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c43487744.condition)
	e1:SetOperation(c43487744.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：确认效果发动方为对方、发动的是“黑洞”卡的发动，满足条件时本卡可以发动。
function c43487744.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(53129443)
end
-- 效果处理：获取当前连锁中的“黑洞”效果，并为己方场上怪兽赋予一次对该“黑洞”效果的保护，使其不会被那张“黑洞”破坏。
function c43487744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中“黑洞”效果的连锁ID，用于后续标记是哪一次“黑洞”效果。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 自己场上存在的怪兽不会被那张「黑洞」的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetValue(c43487744.indval)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabel(cid)
	-- 将防破坏效果注册到场上，适用于己方怪兽，并在该连锁处理结束后自动重置。
	Duel.RegisterEffect(e1,tp)
end
-- 判定保护效果是否适用：仅当效果来源是之前记录的那张“黑洞”时，己方怪兽不会被效果破坏。
function c43487744.indval(e,re,rp)
	-- 比较当前正在处理的效果的连锁ID与记录的“黑洞”连锁ID，相同则返回真，使免破坏效果生效。
	return Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==e:GetLabel()
end
