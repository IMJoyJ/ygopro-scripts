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
-- ①效果的发动代价函数：发动时检查并支付600基本分作为COST。
function c19535693.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0）判断玩家是否能支付600基本分，若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 实际支付600基本分作为发动代价。
	Duel.PayLPCost(tp,600)
end
-- 定义①效果检索的过滤条件：需为「朋克」怪兽、不是本卡、可从卡组加入手牌。
function c19535693.thfilter(c)
	return c:IsSetCard(0x171) and not c:IsCode(19535693) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动目标函数：发动时检查卡组中是否存在符合条件的「朋克」怪兽，并设置操作信息为从卡组检索加入手牌。
function c19535693.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认卡组中存在至少1张满足条件的「朋克」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19535693.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明该效果将把1张卡从卡组加入手牌，供连锁响应和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时的操作：从卡组选择1张符合条件的「朋克」怪兽加入手牌，并向对方展示确认。
function c19535693.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片提示，让玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张符合过滤条件的「朋克」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c19535693.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果取对象的过滤条件：己方场上表侧表示且属于「朋克」系列的怪兽。
function c19535693.atkfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- ②效果的发动目标函数：发动时选择自己场上1只表侧表示的「朋克」怪兽作为对象。
function c19535693.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19535693.atkfilter2(chkc) end
	-- 在发动合法性检查阶段，确认自己场上存在至少1只符合条件的「朋克」怪兽可取对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c19535693.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择卡片提示，让玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合条件的「朋克」怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c19535693.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理时的操作：给对象怪兽赋予攻击力上升600的效果。
function c19535693.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
