--素早きは三文の徳
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有衍生物以外的同名怪兽3只的场合才能发动。从卡组把3只同名怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
function c43994202.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽只有衍生物以外的同名怪兽3只的场合才能发动。从卡组把3只同名怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43994202)
	e1:SetCondition(c43994202.condition)
	e1:SetTarget(c43994202.target)
	e1:SetOperation(c43994202.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：判断怪兽是否为表侧表示且不是衍生物，用于后续仅统计场上满足条件的怪兽。
function c43994202.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 发动条件：自己场上怪兽区恰好存在3只怪兽，并且这3只怪兽全部为表侧表示且不是衍生物，同时这3只怪兽卡名相同。
function c43994202.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区的所有怪兽集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==3 and g:FilterCount(c43994202.cfilter,nil)==3
		and g:GetClassCount(Card.GetCode)==1
end
-- 检索第一张同名怪兽的过滤条件：该卡是怪兽、能被加入手卡，并且卡组中还存在至少2张与它卡名相同的怪兽且都能加入手卡，以保证能凑齐3张同名卡。
function c43994202.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 额外检查卡组中是否存在至少2张与c卡号相同且能加入手卡的怪兽，作为凑齐3张同名卡的保证。
		and Duel.IsExistingMatchingCard(c43994202.filter2,tp,LOCATION_DECK,0,2,c,c:GetCode())
end
-- 检索同名怪兽的过滤条件：是怪兽、卡号与指定code相同、且能被加入手卡，用于选择剩余2张同名卡。
function c43994202.filter2(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：若卡组中存在能凑齐3张同名怪兽的候选，则宣告本次处理将从卡组把3张卡加入手卡。
function c43994202.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）确认卡组中是否有满足条件的第1张同名怪兽，若无则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43994202.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：将3张卡从卡组加入手卡（数量3，位置为卡组），供连锁检测和效果结算使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
-- 效果结算：依次选择第1张符合条件的同名怪兽和另外2张同名怪兽，合并为3张后加入手卡，如成功则向对方确认，然后为该玩家设置直到结束阶段不能通常召唤·特殊召唤这些同名怪兽且不能发动这些怪兽效果的誓约限制。
function c43994202.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示，用于第一次选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件（能凑齐3张同名卡）的怪兽，作为第1张加入手卡的卡。
	local g1=Duel.SelectMatchingCard(tp,c43994202.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g1:GetCount()<=0 then return end
	-- 再次显示“请选择要加入手牌的卡”的选择提示，用于后续选择剩余2张。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择2张与第1张卡卡号相同且能加入手卡的怪兽，作为剩余2张加入手卡的卡。
	local g2=Duel.SelectMatchingCard(tp,c43994202.filter2,tp,LOCATION_DECK,0,2,2,g1,g1:GetFirst():GetCode())
	g1:Merge(g2)
	-- 将选出的3张卡以效果原因加入持有者手卡；若实际加入数量大于0则继续执行后续限制。
	if Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
		-- 向对方玩家确认加入手卡的3张怪兽卡，使对方获知加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g1)
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		local code=g1:GetFirst():GetCode()
		-- 这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetCode(EFFECT_CANNOT_ACTIVATE)
		e0:SetTargetRange(1,0)
		e0:SetValue(c43994202.aclimit)
		e0:SetLabel(code)
		e0:SetReset(RESET_PHASE+PHASE_END)
		-- 将禁止发动效果的永续效果注册给当前玩家，持续到结束阶段。
		Duel.RegisterEffect(e0,tp)
		local e1=e0:Clone()
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTarget(c43994202.splimit)
		e1:SetValue(1)
		-- 将禁止通常召唤的誓约效果注册给当前玩家，禁止召唤与加入手卡同卡号的怪兽。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		-- 将禁止覆盖（里侧守备表示放置）的誓约效果注册给当前玩家，禁止覆盖与加入手卡同卡号的怪兽。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 将禁止特殊召唤的誓约效果注册给当前玩家，禁止特殊召唤与加入手卡同卡号的怪兽。
		Duel.RegisterEffect(e3,tp)
	end
end
-- aclimit限制函数：当玩家发动的效果来自怪兽，且该怪兽卡号与加入手卡的同名卡卡号相同时，禁止其效果发动。
function c43994202.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
-- splimit限制函数：被通常召唤/覆盖/特殊召唤的怪兽卡号与加入手卡同名卡卡号相同时，禁止该召唤行为。
function c43994202.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsCode(e:GetLabel())
end
