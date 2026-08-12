--妖精伝姫－カグヤ
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只攻击力1850的魔法师族怪兽加入手卡。
-- ②：自己·对方回合1次，以对方场上1只表侧表示怪兽为对象才能发动。对方可以把1张那只怪兽的同名卡从自身的卡组·额外卡组送去墓地让这个效果无效。没送去墓地的场合，这张卡和作为对象的怪兽回到手卡。
function c86937530.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只攻击力1850的魔法师族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86937530,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c86937530.target)
	e1:SetOperation(c86937530.operation)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，以对方场上1只表侧表示怪兽为对象才能发动。对方可以把1张那只怪兽的同名卡从自身的卡组·额外卡组送去墓地让这个效果无效。没送去墓地的场合，这张卡和作为对象的怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86937530,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c86937530.thtg)
	e2:SetOperation(c86937530.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中攻击力为1850的魔法师族且能加入手牌的怪兽
function c86937530.filter(c)
	return c:IsAttack(1850) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 召唤成功时效果的发动准备与合法性检测，并设置检索的操作信息
function c86937530.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86937530.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 召唤成功时效果的处理，从卡组选择1只满足条件的怪兽加入手牌并给对方确认
function c86937530.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c86937530.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤对方场上表侧表示且能回到手牌的怪兽
function c86937530.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 诱发即时效果的发动准备，选择对方场上1只表侧表示怪兽作为对象，并设置回手牌的操作信息
function c86937530.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以作为对象的表侧表示且能回到手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(c86937530.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86937530.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁的操作信息，表示该效果包含将自身和对象怪兽（共2张卡）送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 过滤对方卡组或额外卡组中与对象怪兽同名且能送去墓地的卡
function c86937530.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGraveAsCost()
end
-- 诱发即时效果的处理，询问对方是否将同名卡送去墓地，若送去则效果无效，否则将自身和对象怪兽送回手牌
function c86937530.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	-- 检查该效果是否可以被无效，且对象怪兽是否仍表侧表示存在
	if Duel.IsChainDisablable(0) and tc:IsFaceup() then
		-- 获取对方卡组及额外卡组中与对象怪兽同名的卡片组
		local g=Duel.GetMatchingGroup(c86937530.cfilter,tp,0,LOCATION_DECK+LOCATION_EXTRA,nil,tc:GetCode())
		local sel=1
		-- 提示对方玩家是否选择将同名卡送去墓地以使该效果无效
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(86937530,2))  --"是否把同名卡送去墓地让这个效果无效？"
		if g:GetCount()>0 then
			-- 对方卡组或额外卡组有同名卡时，让对方选择“是”（送去墓地）或“否”（不送去）
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 对方卡组或额外卡组没有同名卡时，强制对方只能选择“否”（不送去）
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 提示对方玩家选择要送去墓地的同名卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的同名卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
			-- 使当前连锁的效果无效并结束处理
			Duel.NegateEffect(0)
			return
		end
	end
	local rg=Group.FromCards(c,tc)
	-- 对方未将同名卡送去墓地时，将这张卡和作为对象的怪兽全部回到持有者手牌
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
end
