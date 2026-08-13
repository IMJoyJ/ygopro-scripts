--魔術師の左手
-- 效果：
-- ①：1回合1次，自己场上有魔法师族怪兽存在的场合，对方发动的陷阱卡的效果无效并破坏。
function c13758665.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上有魔法师族怪兽存在的场合，对方发动的陷阱卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c13758665.negcon)
	e2:SetOperation(c13758665.negop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡片须为表侧表示且种族为魔法师族，用于检查自己场上是否存在此类怪兽。
function c13758665.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果发动条件：自己场上有表侧表示魔法师族怪兽存在，且当前连锁由对方发动、发动效果的类型为陷阱卡。
function c13758665.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足魔法师族条件的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(c13758665.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_TRAP)
end
-- 效果处理：将对方发动的陷阱卡效果无效，并破坏该陷阱卡。
function c13758665.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示卡号为13758665（魔术师的左手）的卡片发动动画。
	Duel.Hint(HINT_CARD,0,13758665)
	local rc=re:GetHandler()
	-- 判定效果无效是否成功，且该陷阱卡仍在场上/与效果保持关联（未被无效后离场或转移）。
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 以效果原因破坏那张对方陷阱卡。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
