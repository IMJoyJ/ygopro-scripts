--DD魔導賢者ニュートン
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的陷阱卡的效果发动的场合，可以把那个效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 「DD 魔导贤者 牛顿」的怪兽效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃，以「DD 魔导贤者 牛顿」以外的自己墓地1张「DD」卡或者「契约书」卡为对象才能发动。那张卡加入手卡。
function c19302550.initial_effect(c)
	-- 为这张灵摆怪兽添加灵摆召唤与灵摆卡发动的基础属性，使其可以作为灵摆怪兽使用。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19302550.splimit)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的陷阱卡的效果发动的场合，可以把那个效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(c19302550.discon)
	e2:SetOperation(c19302550.disop)
	c:RegisterEffect(e2)
	-- 「DD 魔导贤者 牛顿」的怪兽效果1回合只能使用1次。①：把这张卡从手卡丢弃，以「DD 魔导贤者 牛顿」以外的自己墓地1张「DD」卡或者「契约书」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19302550,0))  --"卡片回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,19302550)
	e3:SetCost(c19302550.thcost)
	e3:SetTarget(c19302550.thtg)
	e3:SetOperation(c19302550.thop)
	c:RegisterEffect(e3)
end
-- 灵摆召唤限制的判定：若要灵摆召唤的怪兽不是「DD」字段的怪兽，则该怪兽不能进行灵摆召唤。
function c19302550.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xaf) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 此效果的发动条件：该连锁效果可被无效且尚未被无效，且该效果是陷阱卡效果、会给己方造成伤害，并且这张卡在本次连锁中尚未发动过此效果（flag为0）。
function c19302550.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该连锁效果是否能够被无效，并且当前还没有被无效化。
	return Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
		-- 同时确认被连锁的效果是陷阱卡效果、会给己方造成伤害，并且这张卡之前没有发动过此效果（利用FlagEffect标记实现1回合1次）。
		and re:IsActiveType(TYPE_TRAP) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetFlagEffect(19302550)==0
end
-- 效果处理：询问己方玩家是否发动此卡效果；若同意则先标记本回合已使用，接着无效被连锁的陷阱效果，然后破坏这张卡。
function c19302550.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 让这张卡的控制者选择是否发动此效果；如果选择否，则直接结束处理。
	if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	e:GetHandler():RegisterFlagEffect(19302550,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 尝试无效被连锁的陷阱卡效果；若无效失败（例如该效果无法被无效），则直接结束，不破坏自身。
	if not Duel.NegateEffect(ev) then return end
	-- 中断当前效果的处理流程，使无效效果与后续的破坏自身视为不同时处理，以正确触发时点。
	Duel.BreakEffect()
	-- 这张卡因自身效果被破坏送去墓地。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 怪兽效果的代价判定：检查这张卡能否从手卡丢弃；若能，则将其丢弃作为发动代价。
function c19302550.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送去墓地，作为丢弃代价（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 检索墓地中符合条件的卡片：拥有「DD」或「契约书」字段、不是这张卡本身、并且可以被加入手卡。
function c19302550.thfilter(c)
	return c:IsSetCard(0xaf,0xae) and not c:IsCode(19302550) and c:IsAbleToHand()
end
-- 发动时的取对象处理：从自己墓地选择1张符合条件的「DD」卡或「契约书」卡作为效果对象，并设置加入手卡的操作信息。
function c19302550.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19302550.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1张符合条件且能够成为效果对象的卡片。
	if chk==0 then return Duel.IsExistingTarget(c19302550.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的卡片作为效果对象（取对象效果，并建立连锁关联）。
	local g=Duel.SelectTarget(tp,c19302550.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：本效果将把1张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得选择的对象卡，若它仍与这个效果关联，则将其加入持有者的手卡。
function c19302550.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果处理时选择的对象卡（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，由效果处理完成回收。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
