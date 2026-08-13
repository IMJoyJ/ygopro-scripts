--滅びの爆裂疾風弾
-- 效果：
-- 这张卡发动的回合，自己不能用「青眼白龙」攻击。
-- ①：自己场上有「青眼白龙」存在的场合才能发动。对方场上的怪兽全部破坏。
function c17655904.initial_effect(c)
	-- 将该卡加入青眼白龙的关联代码列表，注明这张卡效果文中记载了「青眼白龙」，便于相关规则判定。
	aux.AddCodeList(c,89631139)
	-- 这张卡发动的回合，自己不能用「青眼白龙」攻击。①：自己场上有「青眼白龙」存在的场合才能发动。对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c17655904.condition)
	e1:SetCost(c17655904.cost)
	e1:SetTarget(c17655904.target)
	e1:SetOperation(c17655904.activate)
	c:RegisterEffect(e1)
	-- 注册自定义攻击计数器，记录本回合内玩家tp使用非「青眼白龙」的怪兽进行攻击的次数，作为发动时是否满足“尚未用青眼白龙以外怪兽攻击”的判定依据。
	Duel.AddCustomActivityCounter(17655904,ACTIVITY_ATTACK,c17655904.counterfilter)
end
-- 计数器过滤函数：仅当攻击怪兽不是卡号89631139（青眼白龙）时会计数；用青眼白龙攻击不会增加计数。
function c17655904.counterfilter(c)
	return not c:IsCode(89631139)
end
-- 条件过滤函数：判断卡片是否表侧表示且卡名为「青眼白龙」，用于检索自己场上是否存在青眼白龙。
function c17655904.cfilter(c)
	return c:IsFaceup() and c:IsCode(89631139)
end
-- 发动条件函数：效果只能在发动玩家自己场上有至少1张表侧表示「青眼白龙」时满足，否则不能发动。
function c17655904.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp视角的自己场上（怪兽区+魔陷区）是否存在至少1张满足cfilter（表侧青眼白龙）的卡片。
	return Duel.IsExistingMatchingCard(c17655904.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 代价函数：若本回合没有进行过非「青眼白龙」怪兽的攻击，则生成一个影响自己场上所有青眼白龙的“不能攻击”效果，持续到回合结束并带誓约标记；该约束作为发动卡片效果的代价。
function c17655904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段检查自定义攻击计数器为0，即本回合尚未有非「青眼白龙」怪兽攻击过；若已攻击过则不能支付该代价。
	if chk==0 then return Duel.GetCustomActivityCount(17655904,tp,ACTIVITY_ATTACK)==0 end
	-- “这张卡发动的回合，自己不能用「青眼白龙」攻击。”以及“①：自己场上有「青眼白龙」存在的场合才能发动。对方场上的怪兽全部破坏。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 为禁攻效果设置对象过滤器：仅对卡号89631139（青眼白龙）的怪兽生效，即只有青眼白龙不能攻击。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,89631139))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该禁攻效果注册到决斗中，使该回合内玩家tp场上的青眼白龙受到不能攻击的限制，效果在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 目标处理函数：效果发动时确认对方场上存在怪兽，并将对方场上全部怪兽登记为即将被破坏的对象信息，供连锁响应使用。
function c17655904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时判断对方场上怪兽区是否有至少1张怪兽，若对方场上没有怪兽则无法发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上所有怪兽（LOCATION_MZONE）存入sg，用于设置后述的破坏操作信息。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置本连锁的操作信息：效果分类为破坏（CATEGORY_DESTROY），对象是对方场上当前全部怪兽，数量为怪兽数量，使星尘龙等效果能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：实际执行时重新获取对方场上全部怪兽并将其破坏，完成“对方场上的怪兽全部破坏”。
function c17655904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新取得对方场上所有怪兽，确保破坏对象是效果处理时仍在场的对方怪兽。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将取得的对方场上所有怪兽以效果原因（REASON_EFFECT）破坏，若在连锁处理中对象已离场则不会被破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
