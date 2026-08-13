--ラヴァル炎火山の侍女
-- 效果：
-- ①：这张卡被送去墓地时，自己墓地有「熔岩炎火山的侍女」以外的「熔岩」怪兽存在的场合才能发动。从卡组把1只「熔岩」怪兽送去墓地。
function c2407147.initial_effect(c)
	-- ①：这张卡被送去墓地时，自己墓地有「熔岩炎火山的侍女」以外的「熔岩」怪兽存在的场合才能发动。从卡组把1只「熔岩」怪兽送去墓地。
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
-- 定义过滤条件：该卡必须属于「熔岩」（0x39）系列，且不是「熔岩炎火山的侍女」自身（卡号2407147），用于检查墓地是否存在符合条件的其他熔岩怪兽。
function c2407147.cfilter(c)
	return c:IsSetCard(0x39) and not c:IsCode(2407147)
end
-- 发动条件判断：检查自己墓地是否存在至少1张满足cfilter条件的「熔岩」怪兽，对应效果原文中“自己墓地有「熔岩炎火山的侍女」以外的「熔岩」怪兽存在的场合才能发动”。
function c2407147.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查：以tp方视角，检测己方墓地存在至少1张满足cfilter条件的卡，若存在则返回true，允许效果发动。
	return Duel.IsExistingMatchingCard(c2407147.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义从卡组选择送去墓地的卡的条件：该卡必须属于「熔岩」系列、是怪兽卡，并且可以被送去墓地。
function c2407147.filter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 目标与合法性设定：在发动时确认卡组存在符合条件的「熔岩」怪兽，并预先设置后续效果处理要将1张卡从卡组送去墓地的操作信息。
function c2407147.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：如果己方卡组中存在至少1张满足filter条件的「熔岩」怪兽，则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2407147.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本次效果处理会将1张卡从卡组（LOCATION_DECK）送去墓地（CATEGORY_TOGRAVE），因处理时选择对象，targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家tp从卡组选择1只符合条件的「熔岩」怪兽，并将其送去墓地。
function c2407147.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp展示选择提示，提示内容为“请选择要送去墓地的卡”，用于后续卡牌选择界面的文字显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家tp从自己的卡组中筛选并选择1张满足filter条件的「熔岩」怪兽，选择数量固定为1。
	local g=Duel.SelectMatchingCard(tp,c2407147.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡以效果原因（REASON_EFFECT）送入持有者的墓地，完成“从卡组把1只「熔岩」怪兽送去墓地”的处理。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
