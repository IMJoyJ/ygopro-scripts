--教導の神徒
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：融合·同调·超量·连接怪兽被送去自己或者对方的墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合，以「教导的神徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
-- ③：对方怪兽的攻击宣言时才能发动。自己场上的全部「教导」怪兽的攻击力上升500。
function c13694209.initial_effect(c)
	-- ①：融合·同调·超量·连接怪兽被送去自己或者对方的墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13694209,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13694209)
	e1:SetCondition(c13694209.spcon)
	e1:SetTarget(c13694209.sptg)
	e1:SetOperation(c13694209.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合，以「教导的神徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13694209,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,13694210)
	e2:SetCondition(c13694209.thcon)
	e2:SetTarget(c13694209.thtg)
	e2:SetOperation(c13694209.thop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽的攻击宣言时才能发动。自己场上的全部「教导」怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13694209,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13694211)
	e3:SetCondition(c13694209.atkcon)
	e3:SetTarget(c13694209.atktg)
	e3:SetOperation(c13694209.atkop)
	c:RegisterEffect(e3)
end
-- 判断是否有融合·同调·超量·连接怪兽被送去墓地
function c13694209.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 设置特殊召唤的处理目标
function c13694209.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 设置特殊召唤的效果处理函数
function c13694209.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否由手卡特殊召唤
function c13694209.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤墓地中的「教导」卡
function c13694209.thfilter(c)
	return c:IsSetCard(0x145) and not c:IsCode(13694209) and c:IsAbleToHand()
end
-- 设置回手牌的处理目标
function c13694209.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13694209.thfilter(chkc) end
	-- 检查是否有满足条件的墓地卡片
	if chk==0 then return Duel.IsExistingTarget(c13694209.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要回手的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,c13694209.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置回手牌的效果处理函数
function c13694209.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断是否为对方怪兽攻击宣言
function c13694209.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击方为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤场上的「教导」怪兽
function c13694209.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145)
end
-- 设置攻击力上升的处理目标
function c13694209.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有「教导」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13694209.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 设置攻击力上升的效果处理函数
function c13694209.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上的「教导」怪兽
	local g=Duel.GetMatchingGroup(c13694209.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 给目标怪兽的攻击力加上500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
