--浮幽さくら
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，对方场上的怪兽数量比自己场上的怪兽多的场合，把这张卡从手卡丢弃才能发动。选自己的额外卡组1张卡给双方确认。那之后，把对方的额外卡组确认，有选的卡的同名卡的场合，那些对方的同名卡全部除外。
function c62015408.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己·对方回合，对方场上的怪兽数量比自己场上的怪兽多的场合，把这张卡从手卡丢弃才能发动。选自己的额外卡组1张卡给双方确认。那之后，把对方的额外卡组确认，有选的卡的同名卡的场合，那些对方的同名卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,62015408)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c62015408.condition)
	e1:SetCost(c62015408.cost)
	e1:SetTarget(c62015408.target)
	e1:SetOperation(c62015408.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：对方场上怪兽数量多于自己，且自己额外卡组有卡
function c62015408.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否比自己场上的怪兽数量多
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 检查自己额外卡组是否存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_EXTRA,0,1,nil)
end
-- 执行发动代价：将手牌中的这张卡丢弃
function c62015408.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 作为发动代价，将这张卡从手牌丢弃并送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 判断是否满足效果发动目标：玩家可以除外卡片，且双方额外卡组均有卡
function c62015408.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以进行除外操作
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 检查自己额外卡组是否有卡
		and Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)>0
		-- 检查对方额外卡组是否有卡
		and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	-- 设置效果处理的操作信息：从对方额外卡组除外卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 执行效果处理：展示自己额外卡组的1张卡，确认对方额外卡组并除外同名卡
function c62015408.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己的额外卡组中选择1张卡
	local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_EXTRA,0,1,1,nil)
	if sg:GetCount()>0 then
		-- 将选中的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		-- 中断当前效果处理，使后续的确认和除外不与展示自己额外卡组视为同时处理
		Duel.BreakEffect()
		-- 获取对方额外卡组的所有卡片
		local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		-- 让发动效果的玩家确认对方的额外卡组
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(Card.IsCode,nil,sg:GetFirst():GetCode())
		if tg:GetCount()>0 then
			-- 将对方额外卡组中与所选卡同名的卡全部表侧表示除外
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		-- 洗切自己的额外卡组
		Duel.ShuffleExtra(tp)
		-- 洗切对方的额外卡组
		Duel.ShuffleExtra(1-tp)
	end
end
