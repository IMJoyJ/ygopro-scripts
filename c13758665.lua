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
-- 检查场上是否存在表侧表示的魔法师族怪兽
function c13758665.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 连锁处理开始时，满足条件则发动效果
function c13758665.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c13758665.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_TRAP)
end
-- 将对方发动的陷阱卡效果无效并破坏
function c13758665.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示此卡发动
	Duel.Hint(HINT_CARD,0,13758665)
	local rc=re:GetHandler()
	-- 使连锁效果无效并检查卡片是否与效果相关
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 破坏被无效的陷阱卡
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
