--イージーチューニング
-- 效果：
-- ①：从自己墓地把1只调整除外，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力上升因为这张卡发动而除外的调整的攻击力数值。
function c5052212.initial_effect(c)
	-- ①：从自己墓地把1只调整除外，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力上升因为这张卡发动而除外的调整的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为不在伤害步骤或伤害计算后发动，即只能在伤害步骤且伤害计算前满足条件时发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c5052212.cost)
	e1:SetTarget(c5052212.target)
	e1:SetOperation(c5052212.activate)
	c:RegisterEffect(e1)
end
-- 定义调整怪兽的过滤函数：该卡必须是调整怪兽，并且可以作为代价从墓地除外。
function c5052212.cfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：先检测墓地是否存在可除外的调整；若存在则让玩家选择1只，记录其攻击力数值，然后将该调整怪兽除外作为发动代价。
function c5052212.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）确认自己墓地是否存在至少1只满足过滤条件的调整怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c5052212.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送代价选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只符合条件的调整怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c5052212.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 将选择的调整怪兽以表侧表示除外，作为这张卡的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标选择处理：选择自己场上1只表侧表示怪兽作为效果对象，并将其登记为取对象。
function c5052212.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在目标检测阶段确认自己场上是否存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送目标选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若对象仍与该效果相关且表侧表示，则给其赋予攻击力上升效果，上升数值为代价除外的调整怪兽的攻击力数值。
function c5052212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中已选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只自己怪兽的攻击力上升因为这张卡发动而除外的调整的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(e:GetLabel())
		tc:RegisterEffect(e1)
	end
end
