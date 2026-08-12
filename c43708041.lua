--陽炎光輪
-- 效果：
-- 只要这张卡在场上存在，自己可以把名字带有「阳炎兽」的怪兽召唤的场合需要的解放减少1只。此外，可以通过把场上表侧表示存在的这张卡送去墓地，从自己墓地选择「阳炎光轮」以外的1张名字带有「阳炎」的卡加入手卡。
function c43708041.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己可以把名字带有「阳炎兽」的怪兽召唤的场合需要的解放减少1只。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	-- 选择满足「阳炎」字段且非「阳炎光轮」的墓地怪兽作为对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107d))
	e2:SetValue(0x1)
	c:RegisterEffect(e2)
	-- 可以通过把场上表侧表示存在的这张卡送去墓地，从自己墓地选择「阳炎光轮」以外的1张名字带有「阳炎」的卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43708041,0))  --"返回手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c43708041.thcon)
	e3:SetCost(c43708041.thcost)
	e3:SetTarget(c43708041.thtg)
	e3:SetOperation(c43708041.thop)
	c:RegisterEffect(e3)
end
-- 效果适用的条件：此卡处于启用状态
function c43708041.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 支付效果的代价：将此卡送入墓地
function c43708041.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为支付代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选满足「阳炎」字段且非「阳炎光轮」的墓地怪兽
function c43708041.filter(c)
	return c:IsSetCard(0x7d) and not c:IsCode(43708041) and c:IsAbleToHand()
end
-- 选择满足条件的墓地怪兽作为对象并设置效果处理信息
function c43708041.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43708041.filter(chkc) end
	-- 确认场上是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c43708041.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c43708041.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将对象怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理：将对象怪兽加入手牌并确认对方查看
function c43708041.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认查看该怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
