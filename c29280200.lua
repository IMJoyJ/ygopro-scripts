--VS Dr.マッドラヴ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「征服斗魂」魔法·陷阱卡加入手卡。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●暗：选对方场上1只表侧表示怪兽，那个攻击力·守备力下降500。
-- ●暗·地：场上1只守备力最低的怪兽回到持有者手卡。
function c29280200.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「征服斗魂」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29280200,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,29280200)
	e1:SetTarget(c29280200.thtg)
	e1:SetOperation(c29280200.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●暗：选对方场上1只表侧表示怪兽，那个攻击力·守备力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29280200,1))  --"展示暗属性的怪兽"
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,29280201)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c29280200.adcost)
	e3:SetTarget(c29280200.adtg)
	e3:SetOperation(c29280200.adop)
	c:RegisterEffect(e3)
	-- ●暗·地：场上1只守备力最低的怪兽回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29280200,2))  --"展示暗·地属性的怪兽"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,29280201)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(c29280200.rthcost)
	e4:SetTarget(c29280200.rthtg)
	e4:SetOperation(c29280200.rthop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的「征服斗魂」魔法·陷阱卡。
function c29280200.thfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 判断是否满足检索条件。
function c29280200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否存在满足条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c29280200.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断该回合是否已发动过效果。
		and Duel.GetFlagEffect(tp,29280200)==0 end
	-- 注册标识效果，防止该回合再次发动。
	Duel.RegisterFlagEffect(tp,29280200,RESET_CHAIN,0,1)
	-- 设置连锁操作信息，表示将要从卡组检索卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作。
function c29280200.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c29280200.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选手牌中暗属性且未公开的怪兽。
function c29280200.adcfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 执行效果的费用支付。
function c29280200.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手牌中是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c29280200.adcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c29280200.adcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡。
	Duel.ConfirmCards(1-tp,g)
	-- 触发自定义事件，用于记录费用支付。
	Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切自己的手牌。
	Duel.ShuffleHand(tp)
end
-- 判断是否满足发动条件。
function c29280200.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 判断该回合是否已发动过效果。
		and Duel.GetFlagEffect(tp,29280200)==0 end
	-- 注册标识效果，防止该回合再次发动。
	Duel.RegisterFlagEffect(tp,29280200,RESET_CHAIN,0,1)
end
-- 执行效果操作。
function c29280200.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tc then return end
	-- 为选中的怪兽设置攻击力下降500的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end
-- 筛选手牌中同时具有暗和地属性且未公开的怪兽。
function c29280200.rthcfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 执行效果的费用支付。
function c29280200.rthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组。
	local g=Duel.GetMatchingGroup(c29280200.rthcfilter,tp,LOCATION_HAND,0,nil)
	-- 判断是否存在满足条件的卡组组合。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的卡组。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK)
	-- 向对方确认所选的卡。
	Duel.ConfirmCards(1-tp,sg)
	-- 触发自定义事件，用于记录费用支付。
	Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切自己的手牌。
	Duel.ShuffleHand(tp)
end
-- 筛选场上表侧表示且非链接怪兽的怪兽。
function c29280200.rthtgfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_LINK)
end
-- 判断是否满足发动条件。
function c29280200.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组。
	local g=Duel.GetMatchingGroup(c29280200.rthtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetDefense)
	if chk==0 then return tg:IsExists(Card.IsAbleToHand,1,nil)
		-- 判断该回合是否已发动过效果。
		and Duel.GetFlagEffect(tp,29280200)==0 end
	-- 注册标识效果，防止该回合再次发动。
	Duel.RegisterFlagEffect(tp,29280200,RESET_CHAIN,0,1)
	-- 设置连锁操作信息，表示将要将怪兽送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 执行效果操作。
function c29280200.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组。
	local g=Duel.GetMatchingGroup(c29280200.rthtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		local tg=g:GetMinGroup(Card.GetDefense)
		if #tg>1 then
			-- 提示玩家选择要返回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			tg=tg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			-- 显示被选为对象的动画效果。
			Duel.HintSelection(tg)
		end
		-- 将选中的怪兽送回手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
