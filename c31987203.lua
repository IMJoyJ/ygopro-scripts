--死天使ハーヴェスト
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从卡组把1张「升天之黑角笛」加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤·灵摆召唤成功的场合才能发动。从卡组把1张「升天之角笛」加入手卡。
-- ②：这张卡被解放的场合才能发动。这张卡在自己的灵摆区域放置。
function c31987203.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡破坏，从卡组把1张「升天之黑角笛」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31987203,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,31987203)
	e1:SetTarget(c31987203.thtg1)
	e1:SetOperation(c31987203.thop1)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·灵摆召唤成功的场合才能发动。从卡组把1张「升天之角笛」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,31987204)
	e2:SetTarget(c31987203.thtg2)
	e2:SetOperation(c31987203.thop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c31987203.thcon)
	c:RegisterEffect(e3)
	-- ②：这张卡被解放的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCountLimit(1,31987205)
	e4:SetTarget(c31987203.pentg)
	e4:SetOperation(c31987203.penop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的卡片组（卡号为指定code且能加入手牌的卡）
function c31987203.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 设置连锁处理信息：破坏自身并从卡组检索1张「升天之黑角笛」加入手牌
function c31987203.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件（卡组中是否存在1张「升天之黑角笛」）
	if chk==0 then return Duel.IsExistingMatchingCard(c31987203.thfilter,tp,LOCATION_DECK,0,1,nil,50323155) end
	-- 设置连锁处理信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息：从卡组检索1张「升天之黑角笛」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：破坏自身并检索1张「升天之黑角笛」加入手牌
function c31987203.thop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否有效且成功破坏
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张「升天之黑角笛」加入手牌
	local g=Duel.SelectMatchingCard(tp,c31987203.thfilter,tp,LOCATION_DECK,0,1,1,nil,50323155)
	if #g==0 then return end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
-- 判断是否为灵摆召唤成功
function c31987203.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 设置连锁处理信息：从卡组检索1张「升天之角笛」加入手牌
function c31987203.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件（卡组中是否存在1张「升天之角笛」）
	if chk==0 then return Duel.IsExistingMatchingCard(c31987203.thfilter,tp,LOCATION_DECK,0,1,nil,98069388) end
	-- 设置连锁处理信息：从卡组检索1张「升天之角笛」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：检索1张「升天之角笛」加入手牌
function c31987203.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张「升天之角笛」加入手牌
	local g=Duel.SelectMatchingCard(tp,c31987203.thfilter,tp,LOCATION_DECK,0,1,1,nil,98069388)
	if #g==0 then return end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
-- 设置连锁处理信息：检查灵摆区域是否可用
function c31987203.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行效果处理：将自身移至灵摆区域
function c31987203.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
