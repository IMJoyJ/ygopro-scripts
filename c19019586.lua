--ジェムエレファント
-- 效果：
-- 自己的主要阶段时，可以让场上表侧表示存在的这张卡回到手卡。此外，这张卡进行战斗的伤害计算时只有1次，从手卡把1只通常怪兽送去墓地才能发动。这张卡的守备力只在那次伤害计算时上升1000。
function c19019586.initial_effect(c)
	-- 自己的主要阶段时，可以让场上表侧表示存在的这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(19019586,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c19019586.thtg)
	e1:SetOperation(c19019586.thop)
	c:RegisterEffect(e1)
	-- 此外，这张卡进行战斗的伤害计算时只有1次，从手卡把1只通常怪兽送去墓地才能发动。这张卡的守备力只在那次伤害计算时上升1000。
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
-- 效果发动时的目标合法性检查：若检查阶段为0（初次确认），判定此卡是否能够加入手卡；若可以，则登记本次效果处理为返回手牌。
function c19019586.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡作为返回手牌效果的处理对象，数量为1，用于连锁处理及效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍表侧表示且与效果关联，则将其返回持有者手卡。
function c19019586.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡送去持有者手卡，处理原因为效果。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 代价筛选条件：手牌中的通常怪兽且可以作为代价送去墓地。
function c19019586.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGraveAsCost()
end
-- 发动条件：这张卡是正在进行伤害计算的攻击怪兽或攻击对象怪兽。
function c19019586.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断发动效果的卡是否就是参战怪兽（攻击者或被攻击者）。
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 代价检查：确认这张卡本回合尚未发动过该效果，且手牌中存在符合条件的通常怪兽。
function c19019586.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(19019586)==0
		-- 确认手牌中是否存在至少1张满足筛选条件的通常怪兽。
		and Duel.IsExistingMatchingCard(c19019586.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌选择1张符合条件的通常怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c19019586.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为效果代价送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(19019586,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果处理：为这张卡赋予守备力上升1000的效果，持续到伤害计算阶段结束。
function c19019586.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的守备力只在那次伤害计算时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
