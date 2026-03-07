--女神スクルドの託宣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上的怪兽只有「女武神」怪兽的场合，可以从卡组把1张「女神薇儿丹蒂的引导」加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能召唤·特殊召唤。
function c38576155.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，自己场上的怪兽只有「女武神」怪兽的场合，可以从卡组把1张「女神薇儿丹蒂的引导」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38576155+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c38576155.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c38576155.target)
	e2:SetOperation(c38576155.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在非「女武神」怪兽。
function c38576155.thcfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x122)
end
-- 条件函数，判断自己场上是否存在怪兽且没有非「女武神」怪兽。
function c38576155.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 判断自己场上是否存在非「女武神」怪兽。
		and not Duel.IsExistingMatchingCard(c38576155.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于检索「女神薇儿丹蒂的引导」。
function c38576155.thfilter(c)
	return c:IsCode(64961254) and c:IsAbleToHand()
end
-- 发动效果函数，检索并加入手牌「女神薇儿丹蒂的引导」。
function c38576155.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「女神薇儿丹蒂的引导」卡片组。
	local g=Duel.GetMatchingGroup(c38576155.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and c38576155.thcon(e,tp,eg,ep,ev,re,r,rp) and
		-- 询问玩家是否发动效果。
		Duel.SelectYesNo(tp,aux.Stringid(38576155,0)) then  --"是否把「女神薇儿丹蒂的引导」加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 效果目标函数，判断对方卡组是否至少有3张卡。
function c38576155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方卡组是否至少有3张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- 效果处理函数，排序对方卡组最上方3张卡并设置召唤限制。
function c38576155.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方卡组最上方3张卡进行排序。
	Duel.SortDecktop(tp,1-tp,3)
	-- 设置自己不能召唤和特殊召唤非天使族怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38576155.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册召唤限制效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册特殊召唤限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤和特殊召唤非天使族怪兽的判断函数。
function c38576155.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_FAIRY)
end
