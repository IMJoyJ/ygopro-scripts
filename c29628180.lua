--魔弾－デッドマンズ・バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「魔弹」怪兽存在的场合，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c29628180.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「魔弹」怪兽存在的场合，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,29628180+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c29628180.condition)
	e1:SetTarget(c29628180.target)
	e1:SetOperation(c29628180.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示且拥有「魔弹」字段（0x108），用于检索自己场上满足条件的「魔弹」怪兽。
function c29628180.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x108)
end
-- 发动条件：对方发动魔法·陷阱卡、该发动可被无效，且自己场上有表侧表示「魔弹」怪兽时，本卡才能发动。
function c29628180.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定触发者为对方、该连锁是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该发动的连锁可以被无效（Duel.IsChainNegatable）。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1张表侧表示的「魔弹」怪兽，以符合“自己场上有「魔弹」怪兽存在”的发动条件。
		and Duel.IsExistingMatchingCard(c29628180.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时无需选择对象（chk==0直接允许发动），登记“使发动无效”的处理信息；若对方的魔法·陷阱卡可被破坏且仍与连锁相关，则追加登记“破坏”的处理信息。
function c29628180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果包含使对方发动的魔法·陷阱卡的发动无效，对象为当前连锁中的那张卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：追加包含破坏效果，将对方发动的那张魔法·陷阱卡破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效对方发动的魔法·陷阱卡的发动；若无效成功且该卡仍与连锁相关，则将其破坏。
function c29628180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试通过Duel.NegateActivation无效该连锁的发动，并确认对方那张魔法·陷阱卡仍然与当前连锁相关，两者同时成立才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以“效果”为破坏原因，将对方发动的魔法·陷阱卡（eg）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
