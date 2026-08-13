--ワルキューレ・ツヴァイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：这张卡进行战斗的伤害计算后，以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
function c30411385.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30411385,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,30411385)
	e1:SetTarget(c30411385.destg)
	e1:SetOperation(c30411385.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡进行战斗的伤害计算后，以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30411385,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,30411386)
	e4:SetTarget(c30411385.thtg)
	e4:SetOperation(c30411385.thop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件判定与取对象处理：确认可以以对方场上1只怪兽为对象后，选择1只对方怪兽为对象并设置破坏信息。
function c30411385.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果发动时检查是否存在满足条件的对象，即对方场上是否有至少1只怪兽可以作为效果对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象，并自动建立该卡与当前连锁的效果的关联。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,0,1,nil)
	-- 设置本次效果处理将破坏所选择对象卡的操作信息，供后续时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ①效果处理：取得对象怪兽，若该怪兽仍与效果关联，则将其破坏。
function c30411385.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第1个对象卡（此处即被选择为对象的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 墓地过滤器：判断卡片是否为永续魔法卡，并且能够加入手卡。
function c30411385.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- ②效果的发动条件判定与取对象处理：确认自己墓地存在符合条件的永续魔法卡后，选择其中1张作为对象并设置加入手卡的信息。
function c30411385.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30411385.thfilter(chkc) end
	-- 效果发动时检查自己墓地是否存在至少1张符合条件的永续魔法卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c30411385.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1张符合条件的永续魔法卡作为效果对象，并自动建立关联。
	local g=Duel.SelectTarget(tp,c30411385.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次效果处理将选择的卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若该卡仍与效果关联，则将其加入手卡。
function c30411385.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第1个对象卡（此处即被选择为对象的墓地永续魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者的手卡，返回原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
