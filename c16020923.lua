--ピカリ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「“艾”」魔法·陷阱卡加入手卡。
-- ②：以自己场上1只「@火灵天星」怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成4星。
function c16020923.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「“艾”」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16020923,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16020923)
	e1:SetTarget(c16020923.thtg)
	e1:SetOperation(c16020923.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己场上1只「@火灵天星」怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16020923,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,16020924)
	e3:SetTarget(c16020923.lvtg)
	e3:SetOperation(c16020923.lvop)
	c:RegisterEffect(e3)
end
-- 检索过滤器：选择卡组中持有「“艾”」字段且为魔法·陷阱卡的卡，并满足能加入手卡。
function c16020923.thfilter(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件判断与操作信息设置：无取对象，检查卡组是否存在符合条件的卡；若可以发动，则预设置将1张卡加入手卡的操作信息。
function c16020923.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张符合条件的「“艾”」魔法·陷阱卡，存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c16020923.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 预设置效果处理信息：本次效果将把1张卡从卡组加入手卡（数量1，位置为卡组），用于连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：发动者从卡组选择1张符合条件的「“艾”」魔法·陷阱卡加入手卡，并展示给对手确认。
function c16020923.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示消息，提示玩家从卡组选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从卡组选择1张符合条件的「“艾”」魔法·陷阱卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c16020923.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 对象选择过滤器：自己场上表侧表示、属于「@火灵天星」字段且等级不为4的怪兽（等级至少为1）。
function c16020923.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135) and not c:IsLevel(4) and c:IsLevelAbove(1)
end
-- ②效果的发动条件判断与取对象：以自己场上1只符合条件的表侧表示「@火灵天星」怪兽为对象才能发动。
function c16020923.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16020923.lvfilter(chkc) end
	-- 发动合法性检查：自己场上是否存在至少1只符合条件的「@火灵天星」怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c16020923.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送选择提示消息，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动者选择自己场上1只符合条件的「@火灵天星」怪兽，并将其设置为效果的对象。
	Duel.SelectTarget(tp,c16020923.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：若对象怪兽仍在场上且与效果关联，则赋予其“等级变为4星”的效果，持续到回合结束，且不会被无效。
function c16020923.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果的对象怪兽（即被选择的「@火灵天星」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时变成4星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
