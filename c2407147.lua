--ラヴァル炎火山の侍女
-- 效果：
-- ①：这张卡被送去墓地时，自己墓地有「熔岩炎火山的侍女」以外的「熔岩」怪兽存在的场合才能发动。从卡组把1只「熔岩」怪兽送去墓地。
function c2407147.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理卡片被送去墓地时的触发条件
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2407147,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c2407147.condition)
	e1:SetTarget(c2407147.target)
	e1:SetOperation(c2407147.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查是否为「熔岩」怪兽且不是自身
function c2407147.cfilter(c)
	return c:IsSetCard(0x39) and not c:IsCode(2407147)
end
-- 效果发动条件：自己墓地存在「熔岩」怪兽（除自身外）
function c2407147.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在满足条件的「熔岩」怪兽
	return Duel.IsExistingMatchingCard(c2407147.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数：检查是否为「熔岩」怪兽且为怪兽类型且可以送去墓地
function c2407147.filter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理目标设定：从卡组选择1只「熔岩」怪兽送去墓地
function c2407147.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组存在满足条件的「熔岩」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2407147.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理执行：选择并把1只「熔岩」怪兽从卡组送去墓地
function c2407147.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的「熔岩」怪兽
	local g=Duel.SelectMatchingCard(tp,c2407147.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地，原因来自效果
	Duel.SendtoGrave(g,REASON_EFFECT)
end
