--DDケルベロス
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的等级变成4星，攻击力·守备力上升400。
-- 【怪兽效果】
-- ①：这张卡从手卡的灵摆召唤成功时，「DD 刻耳柏洛斯」以外的「DD」怪兽在自己场上存在的场合以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
function c39153655.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤、发动灵摆卡效果等。
	aux.EnablePendulumAttribute(c)
	-- ←6 【灵摆】 6→ ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的等级变成4星，攻击力·守备力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39153655,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c39153655.atktg)
	e2:SetOperation(c39153655.atkop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：这张卡从手卡的灵摆召唤成功时，「DD 刻耳柏洛斯」以外的「DD」怪兽在自己场上存在的场合以自己墓地1张永续魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c39153655.thcon)
	e3:SetTarget(c39153655.thtg)
	e3:SetOperation(c39153655.thop)
	c:RegisterEffect(e3)
end
-- 定义可选择对象的过滤器：表侧表示、属于「DD」系列、当前等级不是4且等级在1以上的怪兽。
function c39153655.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsLevel(4) and c:IsLevelAbove(1)
end
-- 起动效果的目标选择函数：检查指定卡是否合法，发动条件成立时提示玩家从自己场上选择1只符合条件的「DD」怪兽作为对象。
function c39153655.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39153655.filter(chkc) end
	-- 效果发动时自检：若自己场上不存在至少1只符合filter条件的「DD」怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c39153655.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送“请选择表侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合filter条件的「DD」怪兽，并将其设为该效果的对象。
	Duel.SelectTarget(tp,c39153655.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将对象怪兽的等级变成4星，攻击力·守备力各上升400；若对象不再表侧表示或与效果无关则不处理。
function c39153655.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得该效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsLevel(4) then
		-- 那只怪兽的等级变成4星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(400)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)
	end
end
-- 定义用于检查场上是否存在“「DD 刻耳柏洛斯」以外的「DD」怪兽”的过滤器：表侧表示、属于「DD」系列且不是这张卡自身。
function c39153655.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsCode(39153655)
end
-- 怪兽效果的发动条件：这张卡从手牌以灵摆召唤成功，且自己场上存在「DD 刻耳柏洛斯」以外的表侧表示「DD」怪兽。
function c39153655.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_HAND)
		-- 追加条件：自己场上存在至少1只符合cfilter的「DD」怪兽（即本卡以外的「DD」怪兽）。
		and Duel.IsExistingMatchingCard(c39153655.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义墓地中可选择卡的条件：永续魔法卡且能够加入手卡。
function c39153655.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToHand()
end
-- 回手牌效果的目标选择处理：从自己墓地选择1张符合条件的永续魔法卡作为对象，并设置回手牌的操作信息。
function c39153655.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39153655.thfilter(chkc) end
	-- 发动时自检：若自己墓地不存在至少1张符合条件的永续魔法卡，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c39153655.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的永续魔法卡，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,c39153655.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果将把1张卡加入手牌，供连锁与相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：若对象卡仍与效果相关，则将其加入持有者手牌。
function c39153655.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果选择的墓地对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去持有者手牌（即加入手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
