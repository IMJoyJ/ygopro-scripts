--剛鬼ツイストコブラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「刚鬼」怪兽解放，以自己场上1只「刚鬼」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。这个效果在对方回合也能发动。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 固定眼镜蛇」以外的1张「刚鬼」卡加入手卡。
function c97688360.initial_effect(c)
	-- ①：把自己场上1只「刚鬼」怪兽解放，以自己场上1只「刚鬼」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97688360,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97688360)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果在伤害步骤中仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c97688360.atkcost)
	e1:SetTarget(c97688360.atktg)
	e1:SetOperation(c97688360.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 固定眼镜蛇」以外的1张「刚鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97688360,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,97688361)
	e2:SetCondition(c97688360.thcon)
	e2:SetTarget(c97688360.thtg)
	e2:SetOperation(c97688360.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件1：自己场上的「刚鬼」怪兽，且场上存在至少1只其他可以作为此效果对象的「刚鬼」怪兽
function c97688360.atkfilter1(c,tp)
	-- 判断卡片是否为「刚鬼」怪兽，且场上是否存在除自身以外的、可作为效果对象的表侧表示「刚鬼」怪兽
	return c:IsSetCard(0xfc) and Duel.IsExistingTarget(c97688360.atkfilter2,tp,LOCATION_MZONE,0,1,c)
end
-- 定义过滤条件2：自己场上表侧表示的「刚鬼」怪兽
function c97688360.atkfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
-- 定义效果①的Cost（解放怪兽）处理函数
function c97688360.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件1的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c97688360.atkfilter1,1,nil,tp) end
	-- 选择自己场上1只满足过滤条件1的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c97688360.atkfilter1,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetBaseAttack())
	-- 将选择的怪兽解放作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 定义效果①的对象选择与发动准备（Target）处理函数
function c97688360.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97688360.atkfilter2(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的「刚鬼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c97688360.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「刚鬼」怪兽作为效果对象
	Duel.SelectTarget(tp,c97688360.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果①的效果处理（Operation）函数
function c97688360.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义效果②的发动条件判定函数（必须从场上送去墓地）
function c97688360.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义过滤条件：卡组中「刚鬼 固定眼镜蛇」以外的1张「刚鬼」卡，且该卡可以加入手卡
function c97688360.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(97688360) and c:IsAbleToHand()
end
-- 定义效果②的发动准备（Target）处理函数
function c97688360.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97688360.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表明该效果包含将卡组中的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的效果处理（Operation）函数
function c97688360.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c97688360.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
