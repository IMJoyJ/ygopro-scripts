--セフィラの神撃
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，从自己的额外卡组把1只表侧表示的「神数」怪兽除外才能发动。那个发动无效并破坏。
function c35561352.initial_effect(c)
	-- ①：怪兽的效果·魔法·陷阱卡发动时，从自己的额外卡组把1只表侧表示的「神数」怪兽除外才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c35561352.condition)
	e1:SetCost(c35561352.cost)
	e1:SetTarget(c35561352.target)
	e1:SetOperation(c35561352.activate)
	c:RegisterEffect(e1)
end
-- 定义额外卡组中表侧表示的「神数」怪兽且可作为代价除外的筛选函数，供代价检查和选择使用。
function c35561352.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc4) and c:IsAbleToRemoveAsCost()
end
-- 效果发动条件：当前连锁发动的效果必须是怪兽效果或魔法·陷阱卡的发动，且该连锁可以被无效，才能发动本卡。
function c35561352.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动中的效果是否为怪兽效果或魔法·陷阱卡的发动，并确认该连锁可以被无效，条件同时满足时返回 true。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 发动代价：从自己额外卡组选择1张表侧表示的「神数」怪兽除外，包含存在性检查、选择提示、选择和除外支付。
function c35561352.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：在代价确认阶段，检查额外卡组是否存在至少1张满足条件的「神数」表侧怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c35561352.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 显示选择提示消息，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己额外卡组选择1张满足条件的「神数」表侧怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c35561352.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为发动代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时无取对象，先返回 true；随后设置操作信息，标记本效果包含无效发动，并在满足条件时追加破坏分类。
function c35561352.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的发动标记为无效对象（CATEGORY_NEGATE），使系统能识别本效果包含使发动无效的功能。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若发动效果的卡可被破坏且仍与效果关联，将该卡标记为破坏对象（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：对当前连锁的发动进行无效，若无效成功且该卡仍与效果关联，则将其破坏。
function c35561352.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：若连锁的发动被成功无效，且发动效果的卡仍与效果相关，则执行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的那张卡破坏，破坏原因由效果产生。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
