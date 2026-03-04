--機甲部隊の防衛圏
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为攻击对象，也不能作为效果的对象。
-- ②：自己场上的表侧表示的机械族怪兽被战斗·效果破坏的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
function c13247801.initial_effect(c)
	-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为攻击对象，也不能作为效果的对象。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为攻击对象，也不能作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c13247801.tgcon)
	e1:SetValue(c13247801.tgtg)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为攻击对象，也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c13247801.tgcon)
	e2:SetTarget(c13247801.tgtg)
	-- 效果作用：设置不能成为对方效果的对象的过滤函数
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的机械族怪兽被战斗·效果破坏的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13247801,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,13247801)
	e3:SetCondition(c13247801.thcon)
	e3:SetTarget(c13247801.thtg)
	e3:SetOperation(c13247801.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断是否为正面表示的7星以上机械族怪兽
function c13247801.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(7)
end
-- 条件函数：判断自己场上是否存在7星以上的机械族怪兽
function c13247801.tgcon(e)
	-- 规则层面操作：检查自己场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(c13247801.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断是否为正面表示的6星以下机械族怪兽
function c13247801.tgtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelBelow(6)
end
-- 过滤函数：判断被破坏的怪兽是否为正面表示且为机械族
function c13247801.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 条件函数：判断是否满足发动②效果的条件
function c13247801.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13247801.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数：判断墓地中的怪兽是否为机械族且可加入手牌
function c13247801.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果处理函数：设置选择目标并设置操作信息
function c13247801.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13247801.thfilter(chkc) end
	-- 规则层面操作：检查是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(c13247801.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 规则层面操作：选择目标卡
	local g=Duel.SelectTarget(tp,c13247801.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置操作信息，确定要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：执行效果处理
function c13247801.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
