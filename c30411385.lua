--ワルキューレ・ツヴァイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：这张卡进行战斗的伤害计算后，以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
function c30411385.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
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
	-- ②：这张卡进行战斗的伤害计算后，以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
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
-- 检索满足条件的对方场上怪兽作为破坏对象
function c30411385.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否存在满足条件的对方场上怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,0,1,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 执行破坏效果
function c30411385.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义永续魔法卡的筛选条件
function c30411385.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- 检索满足条件的自己墓地永续魔法卡作为回手对象
function c30411385.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30411385.thfilter(chkc) end
	-- 检查是否存在满足条件的自己墓地永续魔法卡
	if chk==0 then return Duel.IsExistingTarget(c30411385.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地一张永续魔法卡作为回手对象
	local g=Duel.SelectTarget(tp,c30411385.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息为回手效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行回手效果
function c30411385.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的回手对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
