--魔救の奇跡－ティアマイト
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、墓地有暗怪兽时卡组检索魔救魔陷效果、以及对方场上怪兽效果发动时翻卡组顶弹卡效果
function s.initial_effect(c)
	-- 添加同调召唤手续：调整1只＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己墓地有暗属性怪兽存在的场合才能发动。从卡组把1张「魔救」魔法·陷阱卡加入手卡。
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
	-- ②：对方场上的怪兽的效果发动时才能发动。从自己卡组上方确认5张卡。那之中有岩石族怪兽的场合，可以选最多有那个数量的对方场上的卡回到手卡。确认的卡用喜欢的顺序回到卡组最下方。
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
-- 墓地怪兽属性过滤：暗属性怪兽
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- ①效果发动条件：自己墓地存在暗属性怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1只暗属性怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 卡组检索过滤条件：「魔救」魔法·陷阱卡且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x140) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果发动准备：设置从卡组检索魔救魔陷卡片的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在满足条件的「魔救」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1张「魔救」魔法·陷阱卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「魔救」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果发动条件：对方在主要怪兽区或场上发动怪兽效果
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 检查是否为对方在怪兽区域发动的怪兽效果
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动准备：检查卡组张数
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 发动条件检查：自己卡组上方至少有5张卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果处理：确认卡组顶5张卡，按岩石族数量选对方场上的卡弹回手卡，并将确认的卡放回卡组最下方
	Duel.ConfirmDecktop(tp,5)
	-- 翻开并确认自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	-- 获取卡组最上方的5张卡组
	if g:GetCount()>0 and g:FilterCount(Card.IsRace,nil,RACE_ROCK)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local ct=g:FilterCount(Card.IsRace,nil,RACE_ROCK)
		-- 判断确认的卡中是否有岩石族怪兽，且对方场上存在可弹回手牌的卡，并询问玩家是否发动弹卡处理
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 统计确认的5张卡中岩石族怪兽的数量
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 提示玩家选择要返回手牌的卡
		Duel.HintSelection(sg)
		-- 从对方场上选择最多等同于岩石族怪兽数量的卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	if g:GetCount()>0 then
		-- 高亮显示选择的对方场上目标卡片
		Duel.SortDecktop(tp,tp,g:GetCount())
		for i=1,g:GetCount() do
			-- 将选中的卡片返回持有者手牌
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 让玩家自由决定确认卡片的顺序，并按顺序放置到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
