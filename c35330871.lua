--彼岸の鬼神 ヘルレイカー
-- 效果：
-- 「善恶的彼岸」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：1回合1次，从手卡把1只「彼岸」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降因为这个效果发动而送去墓地的怪兽的各自数值。这个效果在对方回合也能发动。
-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡送去墓地。
function c35330871.initial_effect(c)
	c:EnableReviveLimit()
	-- 「善恶的彼岸」降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置此卡必须通过仪式召唤才能特殊召唤的条件
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从手卡把1只「彼岸」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降因为这个效果发动而送去墓地的怪兽的各自数值。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	-- 限制此效果只能在伤害步骤前发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c35330871.atkcost)
	e2:SetTarget(c35330871.atktg)
	e2:SetOperation(c35330871.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c35330871.tgcon)
	e3:SetTarget(c35330871.tgtg)
	e3:SetOperation(c35330871.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断手牌中是否存在「彼岸」怪兽且能作为墓地费用
function c35330871.cfilter(c)
	return c:IsSetCard(0xb1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动时，从手牌中选择1只「彼岸」怪兽送去墓地作为费用
function c35330871.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手牌中存在符合条件的「彼岸」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35330871.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只「彼岸」怪兽
	local g=Duel.SelectMatchingCard(tp,c35330871.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 选择效果对象：对方场上1只表侧表示怪兽
function c35330871.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查是否满足发动条件：对方场上存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果：使对象怪兽的攻击力和守备力下降
function c35330871.atkop(e,tp,eg,ep,ev,re,r,rp)
	local cc=e:GetLabelObject()
	local atk=cc:GetAttack()
	local def=cc:GetDefense()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个使对象怪兽攻击力下降的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-atk)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-def)
		tc:RegisterEffect(e2)
	end
end
-- 判断此卡是否从场上送去墓地
function c35330871.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择效果对象：场上1张可送去墓地的卡
function c35330871.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 检查是否满足发动条件：场上存在1张可送去墓地的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张可送去墓地的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：将选中的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 处理效果：将选中的卡送去墓地
function c35330871.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
