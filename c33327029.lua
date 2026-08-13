--メタルフォーゼ・カウンター
-- 效果：
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。从卡组把1只「炼装」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组把1只表侧表示的「炼装」灵摆怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c33327029.initial_effect(c)
	-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。从卡组把1只「炼装」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+33327029)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c33327029.condition)
	e1:SetTarget(c33327029.target)
	e1:SetOperation(c33327029.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组把1只表侧表示的「炼装」灵摆怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 设置②效果的发动的条件为：这张卡送去墓地的回合不能发动（aux.exccon判断当前回合与卡送去墓地的回合是否相同，并考虑返回额外卡组等例外）。
	e2:SetCondition(aux.exccon)
	-- 设定②效果的发动代价：把墓地里的这张卡除外（从墓地除外作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c33327029.thtg)
	e2:SetOperation(c33327029.thop)
	c:RegisterEffect(e2)
	if not c33327029.global_check then
		c33327029.global_check=true
		-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。从卡组把1只「炼装」怪兽特殊召唤。②：把墓地的这张卡除外才能发动。从自己的额外卡组把1只表侧表示的「炼装」灵摆怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c33327029.regcon)
		ge1:SetOperation(c33327029.regop)
		-- 将全局持续效果ge1注册到决斗中（归属玩家0），用于监听场上卡被破坏的事件，为①效果的发动提供时点触发。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判定被破坏的卡是否为玩家tp的场上卡且被战斗或效果破坏（破坏前控制者为tp，破坏前位置在场上）。
function c33327029.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 全局破坏事件的触发条件：统计eg中被破坏的卡分别属于玩家0、玩家1的数量，若有任一方场上的卡被破坏则通过，并将破坏归属（0/1/双方）存入e的label，供后续使用。
function c33327029.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c33327029.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c33327029.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 当满足regcon时，将被破坏的卡组eg作为事件对象，重新触发自定义事件EVENT_CUSTOM+33327029，并将记录到的破坏归属作为ev传递，使e1能够按“自己场上的卡被破坏”进行判断。
function c33327029.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 以eg为对象触发自定义事件EVENT_CUSTOM+33327029，携带原破坏原因/控制方信息，并将e:GetLabel()（破坏方归属）作为ev参数，使e1的condition能据此判断是否为自己场上的卡被破坏。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+33327029,re,r,rp,ep,e:GetLabel())
end
-- ①效果的发动条件：ev（破坏方归属）等于发动者tp，或为双方PLAYER_ALL，即确实有发动者自己场上的卡被战斗或效果破坏。
function c33327029.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- ①效果的特殊召唤对象过滤：卡片须为「炼装」怪兽，且能被当前效果特殊召唤（检查召唤条件/苏生限制）。
function c33327029.filter(c,e,tp)
	return c:IsSetCard(0xe1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时选择目标：若chk==0（发动合法性检查），需要自己场上存在可用怪兽区且卡组中存在符合条件的「炼装」怪兽；满足后登记将从卡组特殊召唤1只怪兽的操作信息。
function c33327029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：要求发动者tp的怪兽区有空位，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时要求卡组中存在至少1张满足c33327029.filter的「炼装」怪兽，否则不能发动①效果。
		and Duel.IsExistingMatchingCard(c33327029.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁的操作信息：从卡组特殊召唤1只怪兽（目标玩家tp，位置为卡组），用于效果发动检测和相关卡片互动（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若自己场上仍有怪兽区空格，则提示玩家选择卡组中1张符合条件的「炼装」怪兽，将其表侧表示特殊召唤到自己场上。
function c33327029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用怪兽区，若没有则特殊召唤不进行，效果处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家tp显示“请选择要特殊召唤的卡”的提示信息，用于选择卡组中的特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从卡组中选择1张满足c33327029.filter的「炼装」怪兽作为特殊召唤对象，选择的卡存入g。
	local g=Duel.SelectMatchingCard(tp,c33327029.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将g中的怪兽以表侧表示特殊召唤到tp场上，同时检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的对象过滤：卡片须为表侧表示的「炼装」灵摆怪兽，且可以被加入手卡（不受“不能加入手卡”效果限制）。
function c33327029.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xe1) and c:IsAbleToHand()
end
-- ②效果发动时选择目标：若chk==0，确认额外卡组存在至少1张满足thfilter的表侧「炼装」灵摆怪兽；满足后登记从额外卡组将1张卡加入手卡的操作信息。
function c33327029.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：要求自己的额外卡组中存在至少1张表侧表示、符合「炼装」灵摆条件且能被加入手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c33327029.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 登记本次连锁的操作信息：从额外卡组将1张卡加入手卡（目标玩家tp，位置为额外卡组），用于效果检测和连锁互动。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：提示玩家从额外卡组选择1张表侧表示的「炼装」灵摆怪兽，将其加入持有者手卡，并向对方玩家展示。
function c33327029.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示“请选择要加入手牌的卡”的提示信息，用于选择额外卡组中的表侧灵摆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的额外卡组中选择1张满足thfilter的表侧「炼装」灵摆怪兽，选择的卡存入g。
	local g=Duel.SelectMatchingCard(tp,c33327029.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因（REASON_EFFECT）送到其持有者的手卡，完成加入手卡的步骤。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认，保证信息透明（符合OCG规则中从额外卡组加入手卡需要确认的流程）。
		Duel.ConfirmCards(1-tp,g)
	end
end
