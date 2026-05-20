--ストールターン
-- 效果：
-- ①：可以从自己卡组上面把3张卡里侧表示除外把以下效果发动。
-- ●要让怪兽的召唤·反转召唤·特殊召唤无效的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。
-- ●要让魔法·陷阱卡的发动无效的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。
function c86060749.initial_effect(c)
	-- ①：可以从自己卡组上面把3张卡里侧表示除外把以下效果发动。●要让怪兽的召唤·反转召唤·特殊召唤无效的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。●要让魔法·陷阱卡的发动无效的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c86060749.condition)
	e1:SetCost(c86060749.cost)
	e1:SetTarget(c86060749.target)
	e1:SetOperation(c86060749.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：被连锁的效果必须是怪兽效果、魔法或陷阱卡的发动，且该发动可以被无效，并且该效果是“无效召唤”或“无效魔法·陷阱卡的发动”
function c86060749.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(TYPE_SPELL+TYPE_TRAP)) then return false end
	-- 检查当前连锁的发动是否可以被无效，若不能则返回false
	if not Duel.IsChainNegatable(ev) then return false end
	-- 检查被连锁的效果是否包含“无效召唤”分类，或者包含“无效发动”分类且其针对的是魔法·陷阱卡的发动
	return re:IsHasCategory(CATEGORY_DISABLE_SUMMON) or re:IsHasCategory(CATEGORY_NEGATE) and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 定义效果的发动代价：将自己卡组最上方的3张卡里侧表示除外
function c86060749.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3 end
	-- 阻止系统在后续操作中自动进行洗卡检测
	Duel.DisableShuffleCheck()
	-- 将获取的3张卡作为代价里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 定义效果的发动准备（Target）：检查效果发动的合法性，并设置“无效发动”和“送回卡组”的操作信息
function c86060749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 在发动准备阶段，使用通用合法性检查函数判断被连锁的效果是否可以被无效并送回卡组
	if chk==0 then return aux.ndcon(tp,re) end
	-- 设置操作信息，表示该效果包含“使发动无效”的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) then
		-- 设置操作信息，表示该效果包含“送回卡组”的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 定义效果的处理（Operation）：无效目标效果的发动，并将其送回持有者卡组
function c86060749.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 尝试无效目标效果的发动，并确认该卡在效果处理时仍与该效果相关联
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		rc:CancelToGrave()
		-- 将目标卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
