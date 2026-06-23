--素早きは三文の徳
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有衍生物以外的同名怪兽3只的场合才能发动。从卡组把3只同名怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
function c43994202.initial_effect(c)
	-- ①：自己场上的怪兽只有衍生物以外的同名怪兽3只的场合才能发动。从卡组把3只同名怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
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
-- 过滤函数，用于判断场上怪兽是否为表侧表示且不是衍生物。
function c43994202.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 判断场上是否只有3只表侧表示的非衍生物同名怪兽。
function c43994202.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上所有怪兽的组。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==3 and g:FilterCount(c43994202.cfilter,nil)==3
		and g:GetClassCount(Card.GetCode)==1
end
-- 过滤函数，用于判断卡是否为怪兽且能加入手牌，并且卡组中存在至少2张同名怪兽。
function c43994202.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查卡组中是否存在至少2张同名怪兽。
		and Duel.IsExistingMatchingCard(c43994202.filter2,tp,LOCATION_DECK,0,2,c,c:GetCode())
end
-- 过滤函数，用于判断卡是否为指定代码的怪兽且能加入手牌。
function c43994202.filter2(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:IsAbleToHand()
end
-- 设置连锁处理时的提示信息，表示要从卡组检索3张怪兽卡加入手牌。
function c43994202.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在卡组中是否存在至少1张满足条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c43994202.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置连锁处理时的提示信息，表示要从卡组检索3张怪兽卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
-- 发动效果时，选择1张满足条件的怪兽卡，再选择2张同名怪兽卡，总共3张加入手牌。
function c43994202.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的怪兽卡。
	local g1=Duel.SelectMatchingCard(tp,c43994202.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g1:GetCount()<=0 then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择2张与第一张卡同名的怪兽卡。
	local g2=Duel.SelectMatchingCard(tp,c43994202.filter2,tp,LOCATION_DECK,0,2,2,g1,g1:GetFirst():GetCode())
	g1:Merge(g2)
	-- 将选择的3张卡加入手牌。
	if Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
		-- 确认对方查看加入手牌的卡。
		Duel.ConfirmCards(1-tp,g1)
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		local code=g1:GetFirst():GetCode()
		-- 创建并注册一系列效果，限制玩家在回合结束前不能发动、召唤、覆盖、特殊召唤同名怪兽。
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetCode(EFFECT_CANNOT_ACTIVATE)
		e0:SetTargetRange(1,0)
		e0:SetValue(c43994202.aclimit)
		e0:SetLabel(code)
		e0:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能发动效果的限制效果。
		Duel.RegisterEffect(e0,tp)
		local e1=e0:Clone()
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTarget(c43994202.splimit)
		e1:SetValue(1)
		-- 注册不能通常召唤的限制效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		-- 注册不能覆盖召唤的限制效果。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册不能特殊召唤的限制效果。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 限制效果的判断函数，判断是否为同名怪兽卡的效果。
function c43994202.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
-- 限制效果的判断函数，判断是否为同名怪兽卡。
function c43994202.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsCode(e:GetLabel())
end
