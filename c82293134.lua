--紋章獣レオ
-- 效果：
-- 这张卡召唤的回合的结束阶段时，这张卡破坏。此外，这张卡被送去墓地时，从卡组把「纹章兽 狮子」以外的1只名字带有「纹章兽」的怪兽加入手卡。「纹章兽 狮子」的这个效果1回合只能使用1次。
function c82293134.initial_effect(c)
	-- 这张卡召唤的回合的结束阶段时，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82293134,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c82293134.descon)
	e1:SetTarget(c82293134.destg)
	e1:SetOperation(c82293134.desop)
	c:RegisterEffect(e1)
	-- 此外，这张卡被送去墓地时，从卡组把「纹章兽 狮子」以外的1只名字带有「纹章兽」的怪兽加入手卡。「纹章兽 狮子」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82293134,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,82293134)
	e2:SetTarget(c82293134.thtg)
	e2:SetOperation(c82293134.thop)
	c:RegisterEffect(e2)
end
-- 定义破坏效果的发动条件
function c82293134.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否在当前回合被通常召唤
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:GetTurnID()==Duel.GetTurnCount()
end
-- 定义破坏效果的发动准备（设置操作信息）
function c82293134.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 定义破坏效果的执行函数
function c82293134.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 因效果破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤卡组中「纹章兽 狮子」以外的「纹章兽」怪兽
function c82293134.filter(c)
	return c:IsSetCard(0x76) and not c:IsCode(82293134) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义检索效果的发动准备（设置操作信息）
function c82293134.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的执行函数
function c82293134.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c82293134.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
