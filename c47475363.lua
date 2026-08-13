--波紋のバリア －ウェーブ・フォース－
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。对方场上的攻击表示怪兽全部回到持有者卡组。
function c47475363.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。对方场上的攻击表示怪兽全部回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c47475363.condition)
	e1:SetTarget(c47475363.target)
	e1:SetOperation(c47475363.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件判定函数：检查攻击宣言的怪兽是否为对方怪兽，且该攻击是否为直接攻击。
function c47475363.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件判定：攻击宣言的怪兽由对方控制且当前攻击目标为空，即对方怪兽的直接攻击宣言。
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 定义过滤函数：筛选出攻击表示且可以被返回卡组的怪兽。
function c47475363.filter(c)
	return c:IsAttackPos() and c:IsAbleToDeck()
end
-- 定义效果发动时的目标处理函数：验证存在符合条件的怪兽，并将全部符合条件的怪兽设置为回卡组效果的操作对象。
function c47475363.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：仅当对方场上有至少1只攻击表示且可回卡组的怪兽时，效果才满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c47475363.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足过滤条件的怪兽组，作为后续回卡组效果的处理对象。
	local g=Duel.GetMatchingGroup(c47475363.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理信息：本次处理为回卡组，对象为全部满足条件的怪兽，数量为组内卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：获取对方场上所有满足条件的攻击表示怪兽，若存在则将其全部返回持有者卡组并洗牌。
function c47475363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有攻击表示且可回卡组的怪兽组，用于效果处理。
	local g=Duel.GetMatchingGroup(c47475363.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将获取到的怪兽组全部返回持有者卡组（置于卡组底后洗牌），处理原因记为效果。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
