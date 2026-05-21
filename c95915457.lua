--ミラーバリア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽和对方怪兽进行战斗的战斗步骤才能发动1次。那只对方怪兽破坏。
-- ②：这张卡被破坏的场合才能发动。从卡组把1张「武装转生」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 将「武装转生」加入该卡的关联卡片列表中。
	aux.AddCodeList(c,53770666)
	-- ①：以自己场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_ATTACK+TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合才能发动。从卡组把1张「武装转生」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 处理卡片发动时的标准Cost，用于处理卡片留在场上以及连锁被无效时的送去墓地处理。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁无效时将卡片送去墓地的全局效果。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时，取消将该卡送去墓地的处理（使其正常送去墓地）。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 效果①发动的靶向/对象选择阶段判定。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理信息，表示该效果包含装备卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①发动后的效果处理（将卡片装备给目标怪兽，并赋予其装备效果）。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToChain() or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- ●装备怪兽和对方怪兽进行战斗的战斗步骤才能发动1次。那只对方怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"破坏"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_SZONE)
		e1:SetHintTiming(TIMING_BATTLE_PHASE)
		e1:SetCondition(s.descon)
		e1:SetTarget(s.destg)
		e1:SetOperation(s.desop)
		c:RegisterEffect(e1)
		-- 这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetLabelObject(tc)
		e2:SetValue(s.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备怪兽效果的触发条件判定（必须在战斗阶段中，且自身不在连锁中）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前是否处于战斗阶段。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
		and not c:IsStatus(STATUS_CHAINING)
end
-- 装备怪兽效果发动的靶向判定与破坏信息设置。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler():GetEquipTarget()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 设置连锁处理信息，表示将要破坏进行战斗的对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 装备怪兽效果的实际处理（破坏进行战斗的对方怪兽）。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup()
		and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc:IsType(TYPE_MONSTER) then
		-- 因效果将进行战斗的对方怪兽破坏。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
-- 装备限制条件判定（只能装备给作为对象的那只怪兽）。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤卡组中名为「武装转生」且能加入手牌的卡的条件函数。
function s.filter(c)
	return c:IsCode(53770666) and c:IsAbleToHand()
end
-- 效果②发动的靶向判定与检索信息设置。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「武装转生」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的实际处理（从卡组将「武装转生」加入手牌）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「武装转生」。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
