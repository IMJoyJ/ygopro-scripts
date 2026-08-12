--戦士の生還
-- 效果：
-- ①：以自己墓地1只战士族怪兽为对象才能发动。那只战士族怪兽加入手卡。
function c95281259.initial_effect(c)
	-- ①：以自己墓地1只战士族怪兽为对象才能发动。那只战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95281259.target)
	e1:SetOperation(c95281259.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的战士族且可以加入手牌的怪兽
function c95281259.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果发动时的对象选择与操作信息设置
function c95281259.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c95281259.filter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c95281259.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的战士族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c95281259.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽加入手牌
function c95281259.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
