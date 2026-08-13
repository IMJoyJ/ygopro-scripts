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
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡在灵摆区域发动/放置，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡破坏，从卡组把1张「升天之黑角笛」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31987203,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,31987203)
	e1:SetTarget(c31987203.thtg1)
	e1:SetOperation(c31987203.thop1)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：这张卡召唤·灵摆召唤成功的场合才能发动。从卡组把1张「升天之角笛」加入手卡。
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
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：这张卡被解放的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCountLimit(1,31987205)
	e4:SetTarget(c31987203.pentg)
	e4:SetOperation(c31987203.penop)
	c:RegisterEffect(e4)
end
-- 定义检索过滤器：筛选卡名与指定卡号相同且能够加入手卡的卡片。
function c31987203.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 灵摆效果①的发动条件与对象设定：确认卡组存在「升天之黑角笛」可加入手牌，并记录破坏自身和检索加入手牌的操作信息。
function c31987203.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认卡组中存在符合条件的「升天之黑角笛」（卡号50323155）且能加入手牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c31987203.thfilter,tp,LOCATION_DECK,0,1,nil,50323155) end
	-- 设置操作信息：声明本效果将破坏效果持有者自身1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：声明本效果将把1张卡从卡组加入手牌（处理时选择，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果①的结算处理：先破坏自身，成功后再从卡组选1张「升天之黑角笛」加入手牌并向对方确认。
function c31987203.thop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 结算时检查：若自身已不与效果关联或破坏失败，则不再进行后续检索。
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 向己方玩家显示“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张卡号50323155的「升天之黑角笛」作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c31987203.thfilter,tp,LOCATION_DECK,0,1,1,nil,50323155)
	if #g==0 then return end
	-- 将选中的卡片加入其所有者的手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家展示本次加入手牌的卡片。
	Duel.ConfirmCards(1-tp,g)
end
-- 怪兽效果①的灵摆召唤分支追加条件：确认该卡是以灵摆召唤方式特殊召唤成功的。
function c31987203.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 怪兽效果①的目标设定：发动时确认卡组存在「升天之角笛」，并设置从卡组加入手牌的操作信息。
function c31987203.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在符合条件的「升天之角笛」（卡号98069388）且能加入手牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c31987203.thfilter,tp,LOCATION_DECK,0,1,nil,98069388) end
	-- 设置操作信息：声明本效果将把1张卡从卡组加入手牌（处理时选择，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的结算处理：从卡组选1张「升天之角笛」加入手牌并向对方确认。
function c31987203.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家显示“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张卡号98069388的「升天之角笛」作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c31987203.thfilter,tp,LOCATION_DECK,0,1,1,nil,98069388)
	if #g==0 then return end
	-- 将选中的卡片加入其所有者的手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家展示本次加入手牌的卡片。
	Duel.ConfirmCards(1-tp,g)
end
-- 怪兽效果②的目标设定：仅当己方灵摆区域存在可用的空格时才可发动。
function c31987203.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认己方灵摆区域的左/右任一格子为空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的结算处理：若自身仍与效果关联，则将自己移动到灵摆区域。
function c31987203.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到己方灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
