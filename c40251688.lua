--焔聖騎士導－ローラン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。这个回合的结束阶段，从卡组把1张装备魔法卡送去墓地。那之后，从卡组把1只战士族怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，自己·对方的主要阶段，以自己场上1只战士族怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
function c40251688.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整（任意）+调整以外的怪兽1只，使其可作为同调素材进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。这个回合的结束阶段，从卡组把1张装备魔法卡送去墓地。那之后，从卡组把1只战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,40251688)
	e1:SetCondition(c40251688.regcon)
	e1:SetOperation(c40251688.regop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己·对方的主要阶段，以自己场上1只战士族怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,40251689)
	e2:SetCondition(c40251688.eqcon)
	e2:SetTarget(c40251688.eqtg)
	e2:SetOperation(c40251688.eqop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：判定这张卡是否是以同调召唤方式特殊召唤成功，成功时才满足发动条件。
function c40251688.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选卡组中满足“装备魔法卡”且可以送去墓地的卡，作为①效果中要送去墓地的装备魔法卡。
function c40251688.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- 筛选卡组中满足“战士族怪兽”且可以加入手卡的卡，作为①效果中检索加入手卡的战士族怪兽。
function c40251688.thfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果①发动成功后，注册一个到结束阶段再处理的持续效果，使“从卡组送墓装备魔法卡”和“从卡组加入战士族怪兽”延迟到结束阶段执行。
function c40251688.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从卡组把1张装备魔法卡送去墓地。那之后，从卡组把1只战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c40251688.thcon)
	e1:SetOperation(c40251688.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的结束阶段触发效果注册给当前玩家tp，使其在结束阶段时由tp触发并处理。
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段触发效果的发动条件：检查tp的卡组中是否存在可送去墓地的装备魔法卡，存在时才可发动处理。
function c40251688.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查tp的卡组中是否存在至少1张满足tgfilter（装备魔法卡且能送去墓地）的卡。
	return Duel.IsExistingMatchingCard(c40251688.tgfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 结束阶段实际执行的操作：从卡组选1张装备魔法卡送去墓地；若成功，再从卡组选1只战士族怪兽加入手牌并向对方展示。
function c40251688.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示焰圣骑士导-罗兰的卡片动画，提示该效果正在处理。
	Duel.Hint(HINT_CARD,0,40251688)
	-- 为玩家tp弹出“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家tp从自己卡组选择1张满足tgfilter（装备魔法卡且能送去墓地）的卡。
	local g=Duel.SelectMatchingCard(tp,c40251688.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认所选卡存在、已被效果成功送去墓地且确实在墓地中，才继续执行后续检索战士族怪兽的处理。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 取得tp卡组中所有满足thfilter（战士族怪兽且能加入手卡）的卡，作为可检索的候选集合。
		local sg=Duel.GetMatchingGroup(c40251688.thfilter,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，将“送墓”和“加入手卡”视为不同时处理，体现效果原文中“那之后”的先后顺序，避免错过时点。
			Duel.BreakEffect()
			-- 为玩家tp弹出“请选择要加入手牌的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选出的战士族怪兽送去持有者的手卡（nil表示到其持有者手卡）。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方（1-tp）展示加入手卡的战士族怪兽，使对方确认检索结果。
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
-- 效果②的发动条件：仅限自己或对方的主要阶段才能发动，对应“自己·对方的主要阶段”。
function c40251688.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，是则满足②效果的发动时机。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选自己场上表侧表示的战士族怪兽，作为②效果装备的对象。
function c40251688.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果②的目标选择处理：发动时检查自己后场有空位且存在可选的战士族怪兽；选择对象时验证指定卡是否为合法目标。
function c40251688.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40251688.eqfilter(chkc) end
	-- 发动效果时检查自己魔法与陷阱区域是否有空位，以确定能否装备这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己怪兽区域是否存在可被选择为对象的表侧表示战士族怪兽。
		and Duel.IsExistingTarget(c40251688.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 为玩家tp弹出“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家tp从自己场上选择1只表侧表示战士族怪兽，并将其设为该连锁的效果对象。
	Duel.SelectTarget(tp,c40251688.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向系统登记本次操作信息：将这张卡作为装备卡装备给对象，数量为1，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 向系统登记本次操作信息：这张卡会从墓地离开（作为装备卡），数量为1，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②实际处理：把这张卡从墓地装备给自己场上的目标战士族怪兽，并附加只能装备该对象和攻击力上升500的效果。
function c40251688.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽（自己场上的战士族怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 尝试将这张卡作为装备卡装备给对象怪兽；若装备失败则结束处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c40251688.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力上升500。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 判定装备限制：只有这张卡装备时指定的对象怪兽才能成为其装备对象。
function c40251688.eqlimit(e,c)
	return c==e:GetLabelObject()
end
