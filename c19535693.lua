--No－P.U.N.K.セアミン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分才能发动。从卡组把「能朋克 世阿弥」以外的1只「朋克」怪兽加入手卡。
-- ②：这张卡被送去墓地的场合，以自己场上1只「朋克」怪兽为对象才能发动。那只怪兽的攻击力上升600。
function c19535693.initial_effect(c)
	-- ①：支付600基本分才能发动。从卡组把「能朋克 世阿弥」以外的1只「朋克」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19535693,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19535693)
	e1:SetCost(c19535693.thcost)
	e1:SetTarget(c19535693.thtg)
	e1:SetOperation(c19535693.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己场上1只「朋克」怪兽为对象才能发动。那只怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19535693,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,19535694)
	e2:SetTarget(c19535693.atktg2)
	e2:SetOperation(c19535693.atkop2)
	c:RegisterEffect(e2)
end
-- 支付600基本分的费用处理
function c19535693.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 让玩家支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 检索条件过滤函数，筛选「朋克」怪兽且不是自身卡号的怪兽
function c19535693.thfilter(c)
	return c:IsSetCard(0x171) and not c:IsCode(19535693) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 设置效果发动时的处理信息，准备从卡组检索一张「朋克」怪兽加入手牌
function c19535693.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「朋克」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19535693.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，选择并把符合条件的怪兽加入手牌
function c19535693.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c19535693.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 取对象效果的过滤函数，筛选场上表侧表示的「朋克」怪兽
function c19535693.atkfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- 设置效果发动时的处理信息，选择场上一只「朋克」怪兽作为对象
function c19535693.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19535693.atkfilter2(chkc) end
	-- 检查场上是否存在满足条件的「朋克」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c19535693.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一只「朋克」怪兽作为对象
	Duel.SelectTarget(tp,c19535693.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数，使对象怪兽攻击力上升600
function c19535693.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给对象怪兽增加600攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
