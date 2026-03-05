--ジェムエレファント
-- 效果：
-- 自己的主要阶段时，可以让场上表侧表示存在的这张卡回到手卡。此外，这张卡进行战斗的伤害计算时只有1次，从手卡把1只通常怪兽送去墓地才能发动。这张卡的守备力只在那次伤害计算时上升1000。
function c19019586.initial_effect(c)
	-- 效果原文：自己的主要阶段时，可以让场上表侧表示存在的这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(19019586,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c19019586.thtg)
	e1:SetOperation(c19019586.thop)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡进行战斗的伤害计算时只有1次，从手卡把1只通常怪兽送去墓地才能发动。这张卡的守备力只在那次伤害计算时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19019586,1))  --"守备上升1000"
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19019586.defcon)
	e2:SetCost(c19019586.defcost)
	e2:SetOperation(c19019586.defop)
	c:RegisterEffect(e2)
end
-- 检查是否可以将此卡送回手牌
function c19019586.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将此卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行将此卡送回手牌的操作
function c19019586.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将此卡送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤函数：检查手卡中是否存在可作为代价送去墓地的通常怪兽
function c19019586.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGraveAsCost()
end
-- 判断此卡是否参与了攻击或被攻击
function c19019586.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 此卡参与了攻击或被攻击
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 检查是否满足发动条件：未使用过此效果且手卡有通常怪兽可送墓
function c19019586.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(19019586)==0
		-- 手卡存在可送墓的通常怪兽
		and Duel.IsExistingMatchingCard(c19019586.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只手卡中的通常怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c19019586.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(19019586,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 设置此卡的守备力在伤害计算时增加1000
function c19019586.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果原文：这张卡的守备力只在那次伤害计算时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
