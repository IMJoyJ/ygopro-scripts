--騎士デイ・グレファー
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●自己结束阶段，以自己墓地1张装备魔法卡为对象才能发动。那张卡加入手卡。这个卡名的这个效果1回合只能使用1次。
function c15767889.initial_effect(c)
	-- 调用辅助函数为这张卡赋予二重怪兽属性，使这张卡在场上·墓地存在时当作通常怪兽使用（对应①效果）。
	aux.EnableDualAttribute(c)
	-- ●自己结束阶段，以自己墓地1张装备魔法卡为对象才能发动（这个卡名的这个效果1回合只能使用1次）。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15767889,0))  --"回收装备魔法"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,15767889)
	e1:SetCondition(c15767889.thcon)
	e1:SetTarget(c15767889.thtg)
	e1:SetOperation(c15767889.thop)
	c:RegisterEffect(e1)
end
-- 定义该诱发效果的发动条件函数：判断效果持有者是否处于再召唤状态，以及当前是否为自己的结束阶段。
function c15767889.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件具体为：效果持有者处于二重再召唤状态（即当作效果怪兽使用）且当前回合玩家是效果的控制者（自己的结束阶段）。
	return e:GetHandler():IsDualState() and Duel.GetTurnPlayer()==tp
end
-- 定义对象筛选条件：这张卡必须是装备魔法卡，并且能够被加入手卡。
function c15767889.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 定义效果发动时的目标选择与操作信息处理：先检查是否存在合法对象，再进行选择提示，指定自己墓地1张装备魔法卡为对象，并设置回手牌的操作信息。
function c15767889.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c15767889.filter(chkc) end
	-- 在效果发动的合法检查阶段，确认自己墓地中存在至少1张满足条件的装备魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c15767889.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向选择玩家显示提示信息，提示内容为“请选择要返回手牌的卡”，用于选择卡片的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己墓地的满足条件的装备魔法卡中选择1张作为效果对象，并自动将该卡设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c15767889.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：效果分类为回手牌（CATEGORY_TOHAND），对象为g，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理时的操作：获取该效果的对象卡，若对象卡仍与该效果存在关联，则将其加入手牌，并让对手确认那张卡。
function c15767889.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果的对象卡（即作为对象选择的自己墓地的装备魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡加入其持有者的手卡，移动原因是效果处理（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对手玩家确认被加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
