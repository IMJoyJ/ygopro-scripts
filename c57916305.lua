--ウィッチクラフト・クリエイション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「魔女术」怪兽加入手卡。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c57916305.initial_effect(c)
	-- ①：从卡组把1只「魔女术」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57916305)
	e1:SetTarget(c57916305.target)
	e1:SetOperation(c57916305.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57916305,0))  --"从卡组加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,57916305)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c57916305.thcon)
	e2:SetTarget(c57916305.thtg)
	e2:SetOperation(c57916305.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以加入手牌的「魔女术」怪兽
function c57916305.filter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备与效果分类设置
function c57916305.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「魔女术」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57916305.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将1只「魔女术」怪兽加入手牌
function c57916305.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c57916305.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示的「魔女术」怪兽
function c57916305.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ②效果的发动条件：自己回合的结束阶段，且自己场上存在「魔女术」怪兽
function c57916305.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c57916305.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动准备：检查自身是否能加入手牌，并设置操作信息
function c57916305.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，表示该效果会将墓地的这张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡加入手牌
function c57916305.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
