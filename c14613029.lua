--ブレンD
-- 效果：
-- 自己场上名字带有「变形斗士」的怪兽有2只以上表侧表示存在的场合，选择对方场上存在的2张卡发动。对方从那之中选择1张，对方选择的1张卡破坏。
function c14613029.initial_effect(c)
	-- 对应效果原文：自己场上名字带有「变形斗士」的怪兽有2只以上表侧表示存在的场合，选择对方场上存在的2张卡发动。对方从那之中选择1张，对方选择的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c14613029.condition)
	e1:SetTarget(c14613029.target)
	e1:SetOperation(c14613029.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选表侧表示且卡名带有「变形斗士」字段的怪兽，用于后续检查场上是否存在满足条件的「变形斗士」怪兽。
function c14613029.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 效果发动条件判定：检查自己场上是否存在至少2只表侧表示的名字带有「变形斗士」的怪兽，满足时效果才可发动。
function c14613029.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在至少2张符合cfilter条件的卡（表侧表示且为「变形斗士」怪兽），若存在则条件成立。
	return Duel.IsExistingMatchingCard(c14613029.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果的目标选择处理：确认对象只能是对方场上的卡；发动时若不存在至少2张对方场上的卡则无法发动；随后提示选择并选择对方场上2张卡作为对象，同时登记破坏的操作信息。
function c14613029.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动时（chk==0）检查是否有可能从对方场上选择至少2张卡作为对象，若不存在合法目标则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 给当前玩家显示“请选择对方的卡”的提示消息，引导玩家选择对方场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 让当前玩家从对方场上选择2张卡（任意卡）作为效果对象，并将这些卡登记为当前连锁的目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置操作信息：将选择的对象组g标记为将要破坏的卡，数量为1（后续实际破坏其中1张），用于连锁判定和效果时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取连锁对象并过滤出仍与效果相关的卡；若对象数为0则终止，若只有1张则直接将其破坏，否则由对方从这些卡中选择1张并破坏。
function c14613029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的目标卡组（即发动时选择的对方场上的2张卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==0 then return
	elseif sg:GetCount()==1 then
		-- 当筛选后的相关对象只剩1张时，以效果原因将该卡破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	else
		-- 效果处理时给对方玩家显示“请选择要破坏的卡”的提示消息，引导对方选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=sg:Select(1-tp,1,1,nil)
		-- 将对方选择的1张卡以效果原因破坏。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
