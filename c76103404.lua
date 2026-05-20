--サイバー・プチ・エンジェル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只「电子化天使」怪兽或者1张「机械天使的仪式」加入手卡。
function c76103404.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只「电子化天使」怪兽或者1张「机械天使的仪式」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76103404,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,76103404)
	e1:SetTarget(c76103404.thtg)
	e1:SetOperation(c76103404.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「电子化天使」怪兽或「机械天使的仪式」且能加入手卡的卡片
function c76103404.thfilter(c)
	return ((c:IsSetCard(0x2093) and c:IsType(TYPE_MONSTER)) or c:IsCode(39996157)) and c:IsAbleToHand()
end
-- 效果发动的目标确认与操作信息设置
function c76103404.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c76103404.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果的处理为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行，从卡组选择1张符合条件的卡加入手卡并给对方确认
function c76103404.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示，要求玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c76103404.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
