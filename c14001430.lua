--マドルチェ・シャトー
-- 效果：
-- ①：作为这张卡的发动时的效果处理，自己墓地有「魔偶甜点」怪兽存在的场合，那些全部回到卡组。
-- ②：只要这张卡在场地区域存在，场上的「魔偶甜点」怪兽的攻击力·守备力上升500。
-- ③：「魔偶甜点」怪兽的效果让自己墓地的怪兽回到卡组的场合，也能不回到卡组回到手卡。
function c14001430.initial_effect(c)
	-- 对应效果原文①：作为这张卡的发动时的效果处理，自己墓地有「魔偶甜点」怪兽存在的场合，那些全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14001430.target)
	e1:SetOperation(c14001430.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文②：只要这张卡在场地区域存在，场上的「魔偶甜点」怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设定该永续效果的作用对象：场上所有表侧表示且持有「魔偶甜点」字段（0x71）的怪兽，只有这些怪兽会被赋予攻击力上升效果。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x71))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 对应效果原文③：「魔偶甜点」怪兽的效果让自己墓地的怪兽回到卡组的场合，也能不回到卡组回到手卡。此处注册效果代替送往墓地的替换处理，实际改变去向逻辑由c14001430.reptg完成。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTarget(c14001430.reptg)
	e4:SetValue(c14001430.repval)
	c:RegisterEffect(e4)
end
-- 筛选自己墓地中存在的、卡名为「魔偶甜点」字段的、且可以被送回卡组的怪兽卡（用于①的处理）。
function c14001430.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- ①效果的发动条件判定和操作信息登记：只要可以发动就返回 true；发动时将检索到墓地中满足 tdfilter 的「魔偶甜点」怪兽，并把这些卡和数量写入连锁操作信息，标记为回卡组效果。
function c14001430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己墓地中所有满足 c14001430.tdfilter 条件的「魔偶甜点」怪兽，得到待送回卡组的卡组对象。
	local g=Duel.GetMatchingGroup(c14001430.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将待回卡组的 g 组卡及数量写入当前连锁的操作信息，指明这些卡将以 CATEGORY_TODECK 的效果被处理，以便其他卡片（如星尘龙）进行连锁。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ①效果处理时：再次获取自己墓地中符合条件的「魔偶甜点」怪兽；若这些卡受到「王家长眠之谷」等效果限制而无法离开墓地，则本效果不处理；否则将符合条件的所有卡送回卡组并洗牌。
function c14001430.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理阶段重新获取自己墓地中满足 tdfilter 条件的「魔偶甜点」怪兽，以保证使用的是当前实时的墓地状态。
	local g=Duel.GetMatchingGroup(c14001430.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查待送回卡组的 g 是否受「王家长眠之谷」影响；若受其影响，本效果连锁自动被无效并终止。
	if aux.NecroValleyNegateCheck(g) then return end
	if g:GetCount()>0 then
		-- 将 g 中所有卡以效果原因送回持有者的卡组，并执行洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ③的替换对象过滤：判定一张卡是否应当被改为回手牌，条件是该卡在己方墓地、是怪兽、正要回到卡组，且可以加入手牌。
function c14001430.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:GetDestination()==LOCATION_DECK and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end
-- ③的替换效果触发条件：当有卡因效果要回卡组时，需满足是「魔偶甜点」怪兽的效果（REASON_EFFECT 且效果来源为「魔偶甜点」怪兽），且存在至少一张满足 repfilter 的卡，才能发动代替回卡组回手牌。
function c14001430.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSetCard(0x71) and eg:IsExists(c14001430.repfilter,1,nil,tp) end
	-- 发动③的代替效果时，询问玩家是否使用「魔偶甜点城堡」的效果，将本应回卡组的卡改为回手牌。
	if Duel.SelectYesNo(tp,aux.Stringid(14001430,0)) then  --"是否使用「魔偶甜点城堡」的效果？"
		local g=eg:Filter(c14001430.repfilter,nil,tp)
		local ct=g:GetCount()
		if ct>1 then
			-- 当有复数张符合条件的卡时，弹出选择提示，提示玩家选择其中要返回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			g=g:Select(tp,1,ct,nil)
		end
		local tc=g:GetFirst()
		while tc do
			-- 对应效果原文③的后半句：也能不回到卡组回到手卡。为选中的卡赋予回卡组时改为回手牌的重定向效果（EFFECT_TO_DECK_REDIRECT），并带不可无效属性，持续到回合结束。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_DECK_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_HAND)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(14001430,RESET_EVENT+0x1de0000+RESET_PHASE+PHASE_END,0,1)
			tc=g:GetNext()
		end
		-- 对应效果原文③：「魔偶甜点」怪兽的效果让自己墓地的怪兽回到卡组的场合，也能不回到卡组回到手卡。这里是③的后续处理：待回手牌的卡实际进入手牌后确认并洗切手牌，同时注册相关的辅助判定函数。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_TO_HAND)
		e1:SetCountLimit(1)
		e1:SetCondition(c14001430.thcon)
		e1:SetOperation(c14001430.thop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将 c14001430.thop 作为场上持续效果注册给 tp 玩家，用于在③效果回手牌的卡进入手牌后自动执行确认和洗切手牌的操作。
		Duel.RegisterEffect(e1,tp)
		return true
	else return false end
end
-- EFFECT_SEND_REPLACE 的 Value 函数，始终返回 false。实际替换逻辑已在 reptg 的 Target 函数中通过给对象注册回手牌重定向效果完成，因此这里不需要再额外改变去向。
function c14001430.repval(e,c)
	return false
end
-- 判断一张卡是否带有本次③效果设置的标记（14001430 标记），用于确认哪些卡是被改为回手牌的卡。
function c14001430.thfilter(c)
	return c:GetFlagEffect(14001430)~=0
end
-- ③的后续触发条件：当有卡进入手牌时，检查其中是否存在带③效果标记的卡；若有，则进入后续操作。
function c14001430.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14001430.thfilter,1,nil)
end
-- ③的后续操作：取出所有带③效果标记、刚进入手牌的卡，将这些卡展示给对方，然后洗切己方手牌，防止对手通过加入位置获取信息。
function c14001430.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c14001430.thfilter,nil)
	-- 将因③效果回到手牌的 g 组卡片展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切己方手牌使顺序随机化，避免因为原本要回卡组的卡改为回手牌而泄露手牌顺序。
	Duel.ShuffleHand(tp)
end
