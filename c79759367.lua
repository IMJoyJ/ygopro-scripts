--魔導人形の夜
-- 效果：
-- 自己墓地没有怪兽存在的场合才能发动。效果怪兽的效果的发动无效。自己场上有「魔偶甜点·布丁公主」存在的场合，再让对方手卡随机1张回到卡组。
function c79759367.initial_effect(c)
	-- 自己墓地没有怪兽存在的场合才能发动。效果怪兽的效果的发动无效。自己场上有「魔偶甜点·布丁公主」存在的场合，再让对方手卡随机1张回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c79759367.condition)
	e1:SetTarget(c79759367.target)
	e1:SetOperation(c79759367.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：发动效果的卡是怪兽、该发动可以被无效，且自己墓地没有怪兽存在
function c79759367.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的卡是否为怪兽，且该发动是否可以被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查自己墓地是否存在怪兽卡（此处要求不存在）
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 定义发动时的效果处理：设置无效发动的操作信息
function c79759367.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使该怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤条件：自己场上表侧表示的「魔偶甜点·布丁公主」
function c79759367.cfilter(c)
	return c:IsFaceup() and c:IsCode(74641045)
end
-- 定义效果处理：使发动无效，若满足条件则让对方手牌随机1张回到卡组
function c79759367.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，并且自己场上存在表侧表示的「魔偶甜点·布丁公主」
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(c79759367.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且对方手牌数量大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 从对方手牌中随机选择1张卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
		-- 将选中的卡片送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
