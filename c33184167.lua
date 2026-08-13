--同族感染ウィルス
-- 效果：
-- ①：丢弃1张手卡，宣言1个种族才能发动。场上的宣言种族的怪兽全部破坏。
function c33184167.initial_effect(c)
	-- ①：丢弃1张手卡，宣言1个种族才能发动。场上的宣言种族的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33184167,0))  --"宣言种族的怪兽全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c33184167.cost)
	e1:SetTarget(c33184167.target)
	e1:SetOperation(c33184167.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动代价函数：在发动前检查手牌是否有可丢弃的卡；若满足，则选择1张手卡丢弃作为发动代价。
function c33184167.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认我方手牌中存在至少1张可以丢弃的卡，作为效果可以发动的判定条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手牌选择1张可丢弃的卡丢弃，丢弃原因记为COST和DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义筛选函数：用于筛选场上的表侧表示怪兽。
function c33184167.filter(c)
	return c:IsFaceup()
end
-- 定义发动时的目标函数：检查场上有表侧表示怪兽，统计场上表侧怪兽的种族，让玩家宣言1个种族，保存宣言结果并预设定破坏对象。
function c33184167.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认双方主要怪兽区合计存在至少1只表侧表示怪兽，效果才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33184167.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧表示怪兽的集合，用于统计可宣言的种族范围。
	local g=Duel.GetMatchingGroup(c33184167.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local race=0
	while tc do
		race=bit.bor(race,tc:GetRace())
		tc=g:GetNext()
	end
	-- 给玩家发送选择提示，告知接下来需要宣言一个种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让当前玩家从场上表侧怪兽的种族中宣言1个种族，返回宣言的种族值。
	local arc=Duel.AnnounceRace(tp,1,race)
	e:SetLabel(arc)
	local dg=g:Filter(Card.IsRace,nil,arc)
	-- 登记操作信息：将场上宣言种族的表侧表示怪兽设为预定破坏对象，并标明为破坏效果，以便连锁时被检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 定义效果处理时的筛选函数：怪兽须为表侧表示且种族与宣言种族一致。
function c33184167.filter2(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 定义效果处理函数：取出宣言的种族，检索场上符合条件的表侧表示怪兽并全部破坏。
function c33184167.operation(e,tp,eg,ep,ev,re,r,rp)
	local arc=e:GetLabel()
	-- 获取场上所有表侧表示且种族为宣言种族的怪兽集合。
	local g=Duel.GetMatchingGroup(c33184167.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,arc)
	-- 以效果原因破坏该怪兽集合。
	Duel.Destroy(g,REASON_EFFECT)
end
