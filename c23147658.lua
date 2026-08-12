--風化戦士
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。把1张「风化战士」以外的有「化石融合」的卡名记述的卡或者「化石融合」从卡组加入手卡。
-- ②：自己结束阶段发动。这张卡的攻击力下降600。
function c23147658.initial_effect(c)
	-- 记录该卡具有「化石融合」的卡名记述
	aux.AddCodeList(c,59419719)
	-- ①：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。把1张「风化战士」以外的有「化石融合」的卡名记述的卡或者「化石融合」从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23147658,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,23147658)
	e1:SetTarget(c23147658.thtg)
	e1:SetOperation(c23147658.thop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_TO_GRAVE)
	e1x:SetCondition(c23147658.thcon)
	c:RegisterEffect(e1x)
	-- ②：自己结束阶段发动。这张卡的攻击力下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23147658,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c23147658.atkcon)
	e2:SetOperation(c23147658.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的卡：具有「化石融合」的卡名记述且不是风化战士本身且可以加入手牌
function c23147658.thfilter(c)
	-- 具有「化石融合」的卡名记述且不是风化战士本身且可以加入手牌
	return aux.IsCodeOrListed(c,59419719) and not c:IsCode(23147658) and c:IsAbleToHand()
end
-- 判断该卡是否因效果破坏而进入墓地
function c23147658.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 设置效果发动时的处理目标：从卡组检索一张符合条件的卡加入手牌
function c23147658.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在至少一张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23147658.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将一张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择并把符合条件的卡加入手牌
function c23147658.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c23147658.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为自己的结束阶段
function c23147658.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 效果处理函数：使自身攻击力下降600
function c23147658.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使自身攻击力下降600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
