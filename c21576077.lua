--喰光の竜輝巧
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：把墓地的这张卡除外，以自己场上1只「龙辉巧」怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升2000。这个效果在这张卡送去墓地的回合不能发动。
function c21576077.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己墓地1只「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21576077,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,21576077)
	e1:SetTarget(c21576077.target)
	e1:SetOperation(c21576077.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外，以自己场上1只「龙辉巧」怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升2000。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21576077,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21576078)
	-- 设置效果②的发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21576077.atktg)
	e2:SetOperation(c21576077.atkop)
	c:RegisterEffect(e2)
end
-- ①效果的筛选函数：选择自己墓地1只「龙辉巧」怪兽，且该怪兽可以被加入手卡。
function c21576077.filter(c)
	return c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动时目标处理：选择自己墓地1只满足条件的「龙辉巧」怪兽作为对象，并设置回手牌的操作信息。
function c21576077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21576077.filter(chkc) end
	-- 效果发动合法性检查：确认自己墓地存在至少1只符合条件的「龙辉巧」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21576077.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「龙辉巧」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c21576077.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：将对象怪兽加入手牌。
function c21576077.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入手卡（持有者手卡），原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的筛选函数：选择自己场上表侧表示存在的「龙辉巧」怪兽。
function c21576077.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154)
end
-- ②效果的发动时目标处理：选择自己场上1只表侧表示的「龙辉巧」怪兽作为对象。
function c21576077.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21576077.atkfilter(chkc) end
	-- 效果发动合法性检查：确认自己场上存在至少1只表侧表示的「龙辉巧」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21576077.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「龙辉巧」怪兽作为效果对象。
	Duel.SelectTarget(tp,c21576077.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：为对象怪兽附加攻击力上升2000的效果，持续到对方回合结束。
function c21576077.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到对方回合结束时上升2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
