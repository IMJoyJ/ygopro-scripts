--EMリターンタンタン
-- 效果：
-- ←3 【灵摆】 3→
-- 「娱乐伙伴 返回狸」的灵摆效果1回合只能使用1次。
-- ①：以自己场上1张「娱乐伙伴」卡为对象才能发动。那张卡回到持有者手卡。这个回合，自己不能作这个效果回到手卡的卡以及那些同名卡的发动。
-- 【怪兽效果】
-- ①：这张卡被战斗破坏时，以场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c81055000.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡的发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- 「娱乐伙伴 返回狸」的灵摆效果1回合只能使用1次。①：以自己场上1张「娱乐伙伴」卡为对象才能发动。那张卡回到持有者手卡。这个回合，自己不能作这个效果回到手卡的卡以及那些同名卡的发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81055000,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,81055000)
	e1:SetTarget(c81055000.thtg1)
	e1:SetOperation(c81055000.thop1)
	c:RegisterEffect(e1)
	-- ①：这张卡被战斗破坏时，以场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81055000,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(c81055000.thtg2)
	e2:SetOperation(c81055000.thop2)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示且可以回到手牌的「娱乐伙伴」卡片
function c81055000.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsAbleToHand()
end
-- 灵摆效果①的发动准备与对象选择
function c81055000.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c81055000.thfilter(chkc) end
	-- 检查自己场上是否存在可以回到手牌的表侧表示「娱乐伙伴」卡片
	if chk==0 then return Duel.IsExistingTarget(c81055000.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张表侧表示的「娱乐伙伴」卡作为效果对象
	local g=Duel.SelectTarget(tp,c81055000.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果①的效果处理：将目标卡片送回手牌，并注册该卡及同名卡本回合不能发动的限制
function c81055000.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象卡片
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡片是否仍适应效果，并将其送回手牌，确认其已成功回到手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 这个回合，自己不能作这个效果回到手卡的卡以及那些同名卡的发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetCode())
		e1:SetValue(c81055000.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册该限制效果，使其在本回合内生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动的判定函数，阻止与被回手卡片同名的卡片的效果发动
function c81055000.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 怪兽效果①的发动准备与对象选择
function c81055000.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在可以回到手牌的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果①的效果处理：将目标卡片送回持有者手牌
function c81055000.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
