--クリムゾン・ヘル・セキュア
-- 效果：
-- 自己场上有「红莲魔龙」表侧表示存在的场合才能发动。对方场上存在的魔法·陷阱卡全部破坏。
function c50215517.initial_effect(c)
	-- 将卡片密码70902743（红莲魔龙）记录为本卡上记载的卡名，用于后续判定自己场上是否存在红莲魔龙。
	aux.AddCodeList(c,70902743)
	-- 自己场上有「红莲魔龙」表侧表示存在的场合才能发动。对方场上存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c50215517.condition)
	e1:SetTarget(c50215517.target)
	e1:SetOperation(c50215517.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：判断卡片是否为表侧表示且卡号为70902743（红莲魔龙）。
function c50215517.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 定义效果发动条件：检查自己场上是否存在满足cfilter条件的表侧表示的红莲魔龙。
function c50215517.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否至少存在1张表侧表示的红莲魔龙，若存在则发动条件成立。
	return Duel.IsExistingMatchingCard(c50215517.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义过滤函数：判断卡片是否为魔法·陷阱卡。
function c50215517.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果发动时的目标设定与操作信息登记：先确认对方场上有可破坏的魔陷，再获取全部对方场上的魔陷并登记为破坏对象。
function c50215517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性的检查：对方场上若不存在魔法·陷阱卡则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50215517.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有魔法·陷阱卡，作为本次不取对象的破坏候选集合。
	local sg=Duel.GetMatchingGroup(c50215517.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将当前连锁的操作信息设为破坏，目标为sg所有卡，数量为sg的卡数，由于不取对象，玩家和位置参数填0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义效果处理函数：在效果处理时再次获取对方场上所有魔法·陷阱卡并全部破坏。
function c50215517.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有魔法·陷阱卡，并通过aux.ExceptThisCard(e)排除与效果相关的卡（本卡）。
	local sg=Duel.GetMatchingGroup(c50215517.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因（REASON_EFFECT）将选中的魔法·陷阱卡全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
