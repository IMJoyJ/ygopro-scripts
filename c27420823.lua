--K9－17号 “Ripper”
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「K9」卡加入手卡。这个回合对方是已把怪兽的效果发动的场合，可以再从自己的卡组·墓地把1张「K9」速攻魔法卡在自己场上盖放。
-- ②：对方把手卡·墓地的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化该卡的效果：注册XYZ召唤手续和召唤限制，然后分别注册①的起动效果（检索/盖放K9卡）与②的诱发即时效果（无效对方手卡·墓地怪兽效果），并添加一个用于检测对方发动怪兽效果次数的自定义活动计数器。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：将任意2只5星怪兽叠放作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「K9」卡加入手卡。这个回合对方是已把怪兽的效果发动的场合，可以再从自己的卡组·墓地把1张「K9」速攻魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把手卡·墓地的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- 添加一个自定义活动计数器，用于记录“发动怪兽效果”这一行为的次数，供①效果的追加盖放条件判断使用。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 定义计数器过滤函数：若发动的效果不是怪兽效果则返回true；只有发动怪兽效果时才会计入计数（因计数器对过滤函数返回false的操作计数）。
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_MONSTER)
end
-- ①效果的发动代价：检测并支付从这张卡上取除1个超量素材作为COST。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤条件：卡名属于「K9」字段且可以加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1cb) and c:IsAbleToHand()
end
-- ①效果的发动目标：确认卡组中存在满足条件的「K9」卡，并设置本次效果为从卡组将1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中至少存在1张满足s.thfilter过滤条件的「K9」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预定从卡组将1张卡加入持有者手卡，用于效果发动后的连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 追加盖放的过滤条件：属于「K9」字段的速攻魔法卡，且能够被盖放。
function s.setfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- ①效果处理：先检索1张「K9」卡加入手卡并向对方展示，若对方本回合发动过怪兽效果且卡组·墓地存在可盖放的「K9」速攻魔法卡，则询问玩家是否追加盖放，选择后执行盖放。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示消息，供玩家进行选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足s.thfilter条件的「K9」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断检索的卡是否成功加入手卡；成功后才进行后续的确认与追加盖放处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检查己方卡组·墓地中是否存在满足s.setfilter条件的「K9」速攻魔法卡（过滤了受王家长眠之谷影响的卡）。
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			-- 检查对方玩家本回合是否发动过怪兽效果（通过自定义计数器计数是否大于0）。
			and Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
			-- 询问己方玩家是否要追加盖放「K9」速攻魔法卡。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡盖放？"
			-- 中断当前效果的连锁处理，使追加盖放的处理作为独立的时间点处理，避免造成错时点。
			Duel.BreakEffect()
			-- 显示“请选择要盖放的卡”的选择提示消息，供玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 让玩家从己方卡组·墓地选择1张符合条件的「K9」速攻魔法卡。
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选择的「K9」速攻魔法卡盖放在己方魔陷区。
				Duel.SSet(tp,sg)
			end
		end
	end
end
-- ②效果的发动条件：对方玩家在手里或墓地发动怪兽效果，且该效果位于手卡/墓地、属于怪兽效果并可以被无效时，满足发动条件。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置，用于判定是否为手卡或墓地发动的效果。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_HAND+LOCATION_GRAVE)&loc~=0
		-- 判断该连锁是对方发动的怪兽效果，且当前连锁效果能够被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- ②效果的发动代价：检测并支付从这张卡上取除1个超量素材作为COST。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的目标：发动时无需选择对象，直接设置操作信息，指定将当前连锁中发动效果的卡作为无效对象。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理将无效的对象为当前连锁中发动的怪兽效果（eg对应的卡）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：无效对方发动的那个效果。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效操作，使当前连锁的效果无效化。
	Duel.NegateEffect(ev)
end
