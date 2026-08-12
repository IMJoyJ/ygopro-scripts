--サブテラーの導師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把「地中族导师」以外的1张「地中族」卡加入手卡。
-- ②：以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡变成里侧守备表示。自己场上有这张卡以外的「地中族」卡存在的场合，这个效果在对方回合也能发动。
function c16428514.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把「地中族导师」以外的1张「地中族」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16428514,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,16428514)
	e1:SetTarget(c16428514.thtg)
	e1:SetOperation(c16428514.thop)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡变成里侧守备表示。自己场上有这张卡以外的「地中族」卡存在的场合，这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16428514,1))  --"变成里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16428515)
	e2:SetCondition(c16428514.setcon1)
	e2:SetTarget(c16428514.settg)
	e2:SetOperation(c16428514.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c16428514.setcon2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的「地中族」卡（不包括自己）
function c16428514.thfilter(c)
	return c:IsSetCard(0xed) and not c:IsCode(16428514) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息，准备从卡组检索1张「地中族」卡
function c16428514.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足条件的「地中族」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16428514.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的连锁操作信息，准备从卡组检索1张「地中族」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示玩家选择要加入手牌的卡并执行加入手牌和确认操作
function c16428514.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张「地中族」卡
	local g=Duel.SelectMatchingCard(tp,c16428514.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断场上是否有表侧表示的「地中族」卡
function c16428514.setcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xed)
end
-- 条件函数，判断自己场上是否没有其他「地中族」卡
function c16428514.setcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有其他「地中族」卡
	return not Duel.IsExistingMatchingCard(c16428514.setcfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 条件函数，判断自己场上是否存在其他「地中族」卡
function c16428514.setcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在其他「地中族」卡
	return Duel.IsExistingMatchingCard(c16428514.setcfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且可以变为里侧守备表示
function c16428514.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果处理时的连锁操作信息，准备选择目标怪兽并改变其表示形式
function c16428514.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and c16428514.setfilter(chkc) end
	if chk==0 then return c16428514.setfilter(c)
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c16428514.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c16428514.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	g:AddCard(c)
	-- 设置效果处理时的连锁操作信息，准备改变目标怪兽和自身表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end
-- 效果处理函数，将目标怪兽和自身变为里侧守备表示
function c16428514.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将目标怪兽和自身变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
