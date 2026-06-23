--焔聖騎士導－ローラン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。这个回合的结束阶段，从卡组把1张装备魔法卡送去墓地。那之后，从卡组把1只战士族怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，自己·对方的主要阶段，以自己场上1只战士族怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
function c40251688.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
-- 效果条件：确认此卡是否为同调召唤成功
function c40251688.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数：筛选可送去墓地的装备魔法卡
function c40251688.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- 过滤函数：筛选可加入手牌的战士族怪兽
function c40251688.thfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果操作：注册一个在结束阶段触发的效果，用于检索装备魔法卡并加入战士族怪兽
function c40251688.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个在结束阶段触发的效果，用于检索装备魔法卡并加入战士族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c40251688.thcon)
	e1:SetOperation(c40251688.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 效果条件：检查卡组是否存在满足条件的装备魔法卡
function c40251688.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组是否存在至少1张满足条件的装备魔法卡
	return Duel.IsExistingMatchingCard(c40251688.tgfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 效果操作：选择装备魔法卡送去墓地，然后检索战士族怪兽加入手牌
function c40251688.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家发动了此卡
	Duel.Hint(HINT_CARD,0,40251688)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c40251688.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将装备魔法卡送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取卡组中所有满足条件的战士族怪兽
		local sg=Duel.GetMatchingGroup(c40251688.thfilter,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选择的战士族怪兽加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
-- 效果条件：确认当前阶段是否为主阶段1或主阶段2
function c40251688.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前阶段是否为主阶段1或主阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数：筛选场上正面表示的战士族怪兽
function c40251688.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果目标：选择场上正面表示的战士族怪兽作为目标
function c40251688.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40251688.eqfilter(chkc) end
	-- 判断场上是否存在满足条件的战士族怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在满足条件的战士族怪兽
		and Duel.IsExistingTarget(c40251688.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的战士族怪兽作为目标
	Duel.SelectTarget(tp,c40251688.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果操作：将此卡装备给目标怪兽并赋予攻击力上升500的效果
function c40251688.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 尝试将此卡装备给目标怪兽
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备限制效果，确保此卡只能装备给特定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c40251688.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备卡效果，使装备怪兽攻击力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制函数：确保此卡只能装备给特定怪兽
function c40251688.eqlimit(e,c)
	return c==e:GetLabelObject()
end
