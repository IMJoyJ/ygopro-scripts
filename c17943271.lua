--メメント・ゴブリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，对方不能把自己场上的「莫忘」怪兽作为效果的对象。
-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把「莫忘哥布林」以外的最多2张「莫忘」卡送去墓地（同名卡最多1张）。
local s,id,o=GetID()
-- 注册两个效果：①速攻效果（手牌发动）和②起动效果（场上的莫忘怪兽发动）
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，对方不能把自己场上的「莫忘」怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.ltcon)
	e1:SetCost(s.ltcost)
	e1:SetOperation(s.ltop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把「莫忘哥布林」以外的最多2张「莫忘」卡送去墓地（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 用于判断场上的「冥骸合龙-莫忘冥地王灵」是否存在
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(23288411)
end
-- 判断当前是否处于主要阶段1或主要阶段2，并且自己场上有「冥骸合龙-莫忘冥地王灵」
function s.ltcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查自己场上是否存在「冥骸合龙-莫忘冥地王灵」
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动费用：将此卡从手卡丢弃
function s.ltcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手卡丢弃作为发动费用
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动处理：使对方场上所有「莫忘」怪兽不能成为对方效果的对象
function s.ltop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：自己·对方的主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，对方不能把自己场上的「莫忘」怪兽作为效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为所有「莫忘」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1a1))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 设置效果值为tgoval函数，使对方不能以「莫忘」怪兽为对象
	e1:SetValue(aux.tgoval)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 用于筛选场上的「莫忘」怪兽
function s.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 用于筛选卡组中可送去墓地的「莫忘」卡（不包括此卡）
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- 效果②的发动条件：自己场上存在「莫忘」怪兽，且卡组中存在「莫忘」卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的「莫忘」怪兽
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否满足发动条件：场上存在「莫忘」怪兽，且卡组中存在「莫忘」卡
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从卡组选择最多2张「莫忘」卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理：选择1只自己场上的「莫忘」怪兽破坏，然后从卡组选择最多2张「莫忘」卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只自己场上的「莫忘」怪兽进行破坏
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 若破坏失败则返回
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	-- 获取卡组中所有可送去墓地的「莫忘」卡
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡中选择最多2张卡名不同的卡
	local sg=tg:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 将选中的卡送去墓地
	if sg then Duel.SendtoGrave(sg,REASON_EFFECT) end
end
