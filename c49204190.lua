--奇策
-- 效果：
-- ①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降因为这个效果发动而丢弃的怪兽的攻击力数值。
function c49204190.initial_effect(c)
	-- ①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降因为这个效果发动而丢弃的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果只能在非伤害步骤或伤害计算前满足发动条件（aux.dscon限制），即不能在伤害计算时发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c49204190.cost)
	e1:SetTarget(c49204190.target)
	e1:SetOperation(c49204190.activate)
	c:RegisterEffect(e1)
end
-- 定义丢弃手牌的过滤函数：选择攻击力大于0且可以作为代价从手牌丢弃的怪兽。
function c49204190.cfilter(c)
	return c:GetAttack()>0 and c:IsDiscardable()
end
-- 实现发动代价：检查手牌中是否存在可丢弃的怪兽，若存在则提示玩家选择1张，记录其攻击力到效果标签，并将其送入墓地。
function c49204190.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）检查手牌中是否有至少1只满足丢弃条件的怪兽，以判断能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c49204190.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 显示“请选择要丢弃的手牌”的提示信息，引导玩家选择丢弃的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌中选择1张满足条件的怪兽作为丢弃的代价。
	local g=Duel.SelectMatchingCard(tp,c49204190.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的怪兽卡送入墓地，代价原因标记为REASON_COST+REASON_DISCARD，完成丢弃。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 实现取对象处理：选择场上1只表侧表示怪兽作为效果对象，并进行相应的合法性检查。
function c49204190.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在目标检测阶段（chk==0）检查场上是否存在至少1只表侧表示怪兽可以作为对象，以判断能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择表侧表示的卡”的提示信息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象怪兽仍表侧表示且与效果有关联，则给它附加攻击力下降效果，下降数值为丢弃怪兽的攻击力。
function c49204190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力下降因为这个效果发动而丢弃的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
