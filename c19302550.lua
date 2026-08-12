--DD魔導賢者ニュートン
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的陷阱卡的效果发动的场合，可以把那个效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 「DD 魔导贤者 牛顿」的怪兽效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃，以「DD 魔导贤者 牛顿」以外的自己墓地1张「DD」卡或者「契约书」卡为对象才能发动。那张卡加入手卡。
function c19302550.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和灵摆卡的发动
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
-- 限制非DD怪兽进行灵摆召唤
function c19302550.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xaf) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判断是否满足无效陷阱卡效果的条件
function c19302550.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可以被无效且未被无效
	return Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
		-- 检查连锁效果是否为陷阱卡、是否造成玩家伤害且该效果未被使用过
		and re:IsActiveType(TYPE_TRAP) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetFlagEffect(19302550)==0
end
-- 处理无效陷阱卡效果并破坏自身
function c19302550.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动效果
	if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	e:GetHandler():RegisterFlagEffect(19302550,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 尝试使连锁效果无效
	if not Duel.NegateEffect(ev) then return end
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 破坏自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 支付怪兽效果的代价，将自身从手卡丢弃
function c19302550.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选墓地中的DD或契约书卡
function c19302550.thfilter(c)
	return c:IsSetCard(0xaf,0xae) and not c:IsCode(19302550) and c:IsAbleToHand()
end
-- 设置怪兽效果的发动条件和目标选择
function c19302550.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19302550.thfilter(chkc) end
	-- 检查是否存在符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c19302550.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c19302550.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理怪兽效果的发动效果
function c19302550.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
