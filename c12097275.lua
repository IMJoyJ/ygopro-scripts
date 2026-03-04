--剛鬼ハッグベア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤或者用「刚鬼」卡的效果特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 熊抱熊精」以外的1张「刚鬼」卡加入手卡。
function c12097275.initial_effect(c)
	-- ①：这张卡召唤或者用「刚鬼」卡的效果特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetDescription(aux.Stringid(12097275,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,12097275)
	e1:SetTarget(c12097275.atktg)
	e1:SetOperation(c12097275.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c12097275.atkcon)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 熊抱熊精」以外的1张「刚鬼」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12097275,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,12097276)
	e3:SetCondition(c12097275.thcon)
	e3:SetTarget(c12097275.thtg)
	e3:SetOperation(c12097275.thop)
	c:RegisterEffect(e3)
end
-- 效果处理时的Target选择函数，用于选择对方场上的表侧表示怪兽
function c12097275.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断当前是否在选择目标，如果是则返回是否满足条件的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 判断是否满足发动条件，即对方场上是否存在表侧表示且攻击力不为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择对方场上满足条件的1只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时的Operation函数，用于执行攻击力变更效果
function c12097275.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个改变目标怪兽攻击力的效果，将其攻击力变为原来的一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetBaseAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 判断是否满足①效果发动条件，即是否为「刚鬼」卡的效果特殊召唤成功
function c12097275.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0xfc)
end
-- 判断是否满足②效果发动条件，即是否从场上送去墓地
function c12097275.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤函数，用于筛选「刚鬼」卡组中除自身外的卡
function c12097275.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(12097275) and c:IsAbleToHand()
end
-- 效果处理时的Target选择函数，用于选择要加入手卡的「刚鬼」卡
function c12097275.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在满足条件的「刚鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c12097275.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张「刚鬼」卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的Operation函数，用于执行检索并加入手卡效果
function c12097275.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c12097275.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
