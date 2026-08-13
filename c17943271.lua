--メメント・ゴブリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，对方不能把自己场上的「莫忘」怪兽作为效果的对象。
-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把「莫忘哥布林」以外的最多2张「莫忘」卡送去墓地（同名卡最多1张）。
local s,id,o=GetID()
-- 注册这张卡的两个效果：e1为①效果的诱发即时效果（手牌发动，丢弃自身并给「莫忘」怪兽附加保护），e2为②效果的起动效果（场上发动，破坏己方1只「莫忘」怪兽并从卡组送墓「莫忘」卡）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，把这张卡从手卡丢弃才能发动。这个回合中，对方不能把自己场上的「莫忘」怪兽作为效果的对象。
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
-- 过滤函数：判断怪兽是否表侧表示且卡号为23288411（冥骸合龙-莫忘冥地王灵），用于①效果的发动条件。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(23288411)
end
-- ①的发动条件：当前为主要阶段（主要阶段1或2），且自己场上存在表侧的「冥骸合龙-莫忘冥地王灵」。
function s.ltcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查自己场上是否存在至少1张满足s.cfilter的卡，即表侧的「冥骸合龙-莫忘冥地王灵」。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①的代价函数：确认手牌中的这张卡可以被丢弃，并在发动时将其丢弃作为代价。
function s.ltcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将作为代价的这张卡从手牌丢弃送入墓地，原因标记为代价（REASON_COST）并附带丢弃（REASON_DISCARD）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- ①的效果处理：生成一个场地效果，使己方场上的「莫忘」怪兽在这个回合内不会被对方的效果作为对象，且该效果带有无视免疫的效果。
function s.ltop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，对方不能把自己场上的「莫忘」怪兽作为效果的对象。②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把「莫忘哥布林」以外的最多2张「莫忘」卡送去墓地（同名卡最多1张）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该保护效果仅对己方场上满足「莫忘」字段（0x1a1）的卡片生效。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1a1))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 设置效果判定函数为aux.tgoval，即当效果来自对方玩家时返回真，使这些「莫忘」怪兽不能成为对方效果的对象。
	e1:SetValue(aux.tgoval)
	-- 将生成的保护效果注册到tp玩家的场上，效果持续到本回合结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：选择己方场上表侧表示的「莫忘」怪兽，用于②的破坏对象。
function s.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 过滤函数：选择卡组中的「莫忘」卡且可以送去墓地，并且卡名不是「莫忘哥布林」（排除自身卡号id），用于②从卡组送墓。
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- ②的发动目标函数：检查己方场上有可破坏的表侧「莫忘」怪兽，且卡组有至少1张符合条件的「莫忘」卡；并设置破坏1只怪兽和从卡组送1张卡的发动信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上所有表侧表示的「莫忘」怪兽，作为可能被破坏的对象集合。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动合法性判定：己方场上存在至少1只可破坏的「莫忘」怪兽，并且卡组中存在至少1张可送去墓地的非「莫忘哥布林」「莫忘」卡。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将场上所有表侧「莫忘」怪兽设为可能破坏的对象，预计破坏数量为1，分类为CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次处理将从卡组把1张卡送去墓地（分类CATEGORY_TOGRAVE），因具体卡在效果处理时才确定，targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：先选择并破坏己方场上1只表侧「莫忘」怪兽，若破坏成功，则从卡组选择1-2张卡名互不相同的非「莫忘哥布林」「莫忘」卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家从可选择的卡中挑选要破坏的「莫忘」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从己方场上的表侧「莫忘」怪兽中选择1只作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 执行破坏；如果破坏没有成功（破坏数量小于1），则中止后续处理，不再进行卡组送墓。
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	-- 获取卡组中所有满足s.filter的「莫忘」卡，作为可送去墓地的候选集合。
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 弹出选择提示，让玩家选择要送去墓地的「莫忘」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从候选组中选取1-2张卡名互不相同的卡（由aux.dncheck保证同名卡最多1张）。
	local sg=tg:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 若玩家成功选择了送墓的卡，则将这些卡送去墓地。
	if sg then Duel.SendtoGrave(sg,REASON_EFFECT) end
end
