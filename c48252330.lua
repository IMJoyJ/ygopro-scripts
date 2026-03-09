--マドルチェ・バトラスク
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。这张卡召唤成功时，场上有这张卡以外的名字带有「魔偶甜点」的怪兽存在的场合，可以从卡组把1张场地魔法卡加入手卡。
function c48252330.initial_effect(c)
	-- 效果原文：这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48252330,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c48252330.retcon)
	e1:SetTarget(c48252330.rettg)
	e1:SetOperation(c48252330.retop)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡召唤成功时，场上有这张卡以外的名字带有「魔偶甜点」的怪兽存在的场合，可以从卡组把1张场地魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48252330,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c48252330.shcon)
	e2:SetTarget(c48252330.shtg)
	e2:SetOperation(c48252330.shop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断此卡是否因对方破坏而送去墓地且此前在自己控制下
function c48252330.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 规则层面：设置效果处理时将此卡送回卡组的操作信息
function c48252330.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置将此卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 规则层面：执行将此卡送回卡组的效果处理
function c48252330.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面：将此卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 规则层面：过滤函数，用于判断场上是否存在表侧表示的「魔偶甜点」怪兽
function c48252330.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 规则层面：判断召唤成功时场上有无其他「魔偶甜点」怪兽
function c48252330.shcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查场上是否存在满足条件的「魔偶甜点」怪兽
	return Duel.IsExistingMatchingCard(c48252330.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 规则层面：过滤函数，用于筛选可加入手牌的场地魔法卡
function c48252330.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 规则层面：设置效果处理时检索并加入手牌的操作信息
function c48252330.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查卡组中是否存在满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48252330.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置将场地魔法卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行检索并加入手牌的效果处理
function c48252330.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：再次确认场上是否有其他「魔偶甜点」怪兽以确保效果发动条件
	if not Duel.IsExistingMatchingCard(c48252330.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) then return end
	-- 规则层面：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：从卡组中选择一张满足条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c48252330.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的场地魔法卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：向对方确认所选的场地魔法卡
		Duel.ConfirmCards(1-tp,g)
	end
end
