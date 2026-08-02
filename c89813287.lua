--魔救の奇跡－ティアマイト
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 添加同调召唤手续
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己墓地有暗属性怪兽存在的场合，自己主要阶段才能发动。从卡组把1张「魔救」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方在怪兽区域把怪兽的效果发动时才能发动。从自己卡组上面把5张卡翻开。可以根据其中岩石族怪兽的数量，选最多那个数量的对方场上的卡回到手卡。翻开的卡用喜欢的顺序回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon2)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 检查怪兽是否是暗属性
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 判断自己墓地是否有暗属性怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否有暗属性怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 检查卡片是否是能加入手卡的「魔救」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x140) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 加入手卡效果的目标设定
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否有能加入手卡的「魔救」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 加入手卡效果的处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张能加入手卡的「魔救」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否是对方在怪兽区域发动的怪兽效果
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 返回手卡效果的目标设定
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组数量是否大于4张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 返回手卡效果的处理
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己卡组上方5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取卡组上方5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	-- 判断翻开的卡中是否有岩石族怪兽，对方场上是否有能返回手卡的卡，并询问是否发动
	if g:GetCount()>0 and g:FilterCount(Card.IsRace,nil,RACE_ROCK)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local ct=g:FilterCount(Card.IsRace,nil,RACE_ROCK)
		-- 提示选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 根据岩石族怪兽数量选择对方场上最多那个数量的卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 为选中的卡显示被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡返回手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	if g:GetCount()>0 then
		-- 让自己对卡组上方的卡进行排序
		Duel.SortDecktop(tp,tp,g:GetCount())
		for i=1,g:GetCount() do
			-- 获取排序后的卡组最上方1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
