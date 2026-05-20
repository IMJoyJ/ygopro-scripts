--ダイナミスト・チャージ
-- 效果：
-- 「雾动机龙充能」在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「雾动机龙」怪兽加入手卡。
-- ②：1回合1次，「雾动机龙」卡从场上表侧表示加入自己的额外卡组的场合发动。那1张卡加入手卡。
function c77116346.initial_effect(c)
	-- 「雾动机龙充能」在1回合只能发动1张。①：作为这张卡的发动时的效果处理，从卡组把1只「雾动机龙」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,77116346+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c77116346.target)
	e1:SetOperation(c77116346.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，「雾动机龙」卡从场上表侧表示加入自己的额外卡组的场合发动。那1张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c77116346.thcon)
	e2:SetTarget(c77116346.thtg)
	e2:SetOperation(c77116346.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足“雾动机龙”怪兽且能加入手牌的卡
function c77116346.filter(c)
	return c:IsSetCard(0xd8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①发动的目标检查与操作信息设置
function c77116346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足过滤条件的“雾动机龙”怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77116346.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动时效果处理（从卡组选择1只“雾动机龙”怪兽加入手牌并给对方确认）
function c77116346.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的“雾动机龙”怪兽
	local g=Duel.SelectMatchingCard(tp,c77116346.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤从场上表侧表示加入自己额外卡组的“雾动机龙”卡
function c77116346.thfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_EXTRA) and c:IsSetCard(0xd8)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的触发条件（检查是否有满足条件的“雾动机龙”卡加入额外卡组）
function c77116346.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c77116346.thfilter,1,nil,tp)
end
-- 效果②的发动准备（筛选出满足条件的卡并设为效果对象，设置加入手牌的操作信息）
function c77116346.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c77116346.thfilter,nil,tp)
	-- 将满足条件的卡设为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示该效果包含将目标卡片加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理（将成为效果对象且仍存在于额外卡组的1张“雾动机龙”卡加入手牌并给对方确认）
function c77116346.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local rg=g:Select(tp,1,1,nil)
	if rg:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,rg)
	end
end
