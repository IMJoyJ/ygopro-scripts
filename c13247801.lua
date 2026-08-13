--機甲部隊の防衛圏
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为攻击对象，也不能作为效果的对象。
-- ②：自己场上的表侧表示的机械族怪兽被战斗·效果破坏的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
function c13247801.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c13247801.tgcon)
	e1:SetValue(c13247801.tgtg)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有7星以上的机械族怪兽存在，对方不能选择自己场上的6星以下的机械族怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c13247801.tgcon)
	e2:SetTarget(c13247801.tgtg)
	-- 设置“不能成为效果对象”的判定函数：对方发动的效果不能选择自己场上的6星以下机械族表侧怪兽为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上的表侧表示的机械族怪兽被战斗·效果破坏的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
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
-- 判断怪兽是否为表侧表示且为7星以上的机械族，用于①效果的适用条件（自己场上是否存在7星以上机械族怪兽）。
function c13247801.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(7)
end
-- ①效果的适用条件判定：自己场上有表侧表示的7星以上机械族怪兽存在时，①效果适用。
function c13247801.tgcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的7星以上机械族怪兽（①效果的条件成立）。
	return Duel.IsExistingMatchingCard(c13247801.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判断怪兽是否为表侧表示且为6星以下的机械族，即受①效果保护的己方怪兽。
function c13247801.tgtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelBelow(6)
end
-- 判断被破坏的怪兽是否符合②效果触发条件：之前在自己场上表侧表示、控制者为tp、种族为机械、因战斗或效果被破坏且之前位于怪兽区。
function c13247801.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②效果的发动条件：被破坏的怪兽集合中存在至少1只满足sfilter条件的怪兽，且这张卡自身不在被破坏集合中。
function c13247801.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13247801.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的对象过滤条件：对象必须是机械族怪兽且能被加入手卡（满足卡片加入手卡的限制）。
function c13247801.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- ②效果的发动目标处理：从自己墓地选择1只机械族怪兽作为对象，并设定将该卡加入手卡的操作信息。
function c13247801.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13247801.thfilter(chkc) end
	-- 效果发动合法性检查：自己墓地存在至少1只符合条件的机械族怪兽时，才能发动②效果。
	if chk==0 then return Duel.IsExistingTarget(c13247801.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只机械族怪兽作为效果对象，并将该卡设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c13247801.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果处理将把对象卡加入手卡（CATEGORY_TOHAND），供相关卡片的连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：将选择的对象怪兽加入手卡。
function c13247801.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果处理时的对象卡（从自己墓地选择的那只机械族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象机械族怪兽加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
