--超重武者バイ－Q
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，把这张卡从手卡丢弃才能发动。从卡组把「超重武者 摩托-Q」以外的1只「超重武者」怪兽加入手卡。
-- ②：1回合1次，以自己场上1只机械族怪兽为对象才能发动。那只怪兽的等级上升2星。
function c83334932.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己墓地没有魔法·陷阱卡存在的场合，把这张卡从手卡丢弃才能发动。从卡组把「超重武者 摩托-Q」以外的1只「超重武者」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83334932,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,83334932)
	e1:SetCondition(c83334932.condition)
	e1:SetCost(c83334932.cost)
	e1:SetTarget(c83334932.target)
	e1:SetOperation(c83334932.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只机械族怪兽为对象才能发动。那只怪兽的等级上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83334932,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c83334932.lvtg)
	e2:SetOperation(c83334932.lvop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动条件判定函数
function c83334932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法·陷阱卡（若不存在则满足条件）
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- ①号效果的发动代价处理函数
function c83334932.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡从手牌丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「超重武者 摩托-Q」以外的「超重武者」怪兽的条件函数
function c83334932.filter(c)
	return not c:IsCode(83334932) and c:IsSetCard(0x9a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①号效果的发动准备与合法性检测函数
function c83334932.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83334932.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理函数
function c83334932.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local tg=Duel.SelectMatchingCard(tp,c83334932.filter,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤场上表侧表示且等级大于0的机械族怪兽的条件函数
function c83334932.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetLevel()>0
end
-- ②号效果的发动准备与取对象处理函数
function c83334932.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83334932.lvfilter(chkc) end
	-- 检查自己场上是否存在满足条件的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c83334932.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的机械族怪兽作为效果对象
	Duel.SelectTarget(tp,c83334932.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的实际处理函数
function c83334932.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的等级上升2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
