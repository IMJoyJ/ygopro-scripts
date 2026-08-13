--魔導戦士 フォルス
-- 效果：
-- 1回合1次，让自己墓地1张名字带有「魔导书」的魔法卡回到卡组，选择场上1只魔法师族怪兽才能发动。选择的怪兽的等级上升1星，攻击力上升500。
function c13002461.initial_effect(c)
	-- 1回合1次，让自己墓地1张名字带有「魔导书」的魔法卡回到卡组，选择场上1只魔法师族怪兽才能发动。选择的怪兽的等级上升1星，攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13002461,0))  --"等级攻击上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c13002461.cost)
	e1:SetTarget(c13002461.target)
	e1:SetOperation(c13002461.operation)
	c:RegisterEffect(e1)
end
-- 定义代价过滤条件：该卡为名字带有「魔导书」的魔法卡，且可以作为发动代价返回卡组。
function c13002461.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
-- 支付代价：从自己墓地选择1张满足条件的「魔导书」魔法卡返回卡组并洗牌，作为效果发动的代价。
function c13002461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己墓地存在至少1张可作为代价的「魔导书」魔法卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13002461.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张满足条件的「魔导书」魔法卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c13002461.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 为所选的代价卡显示选择动画并记录为广义对象。
	Duel.HintSelection(g)
	-- 将选择的卡返回其持有者卡组并洗牌，完成代价支付。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义取对象过滤条件：对象必须是场上表侧表示的魔法师族怪兽。
function c13002461.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(1)
end
-- 效果发动时的取对象处理：检查是否存在合法对象，并选择场上1只表侧表示魔法师族怪兽作为效果对象。
function c13002461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13002461.filter(chkc) end
	-- 发动检测：确认场上存在至少1只表侧表示的魔法师族怪兽，才能发动该效果。
	if chk==0 then return Duel.IsExistingTarget(c13002461.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示魔法师族怪兽作为效果对象，并登记为取对象。
	Duel.SelectTarget(tp,c13002461.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象怪兽仍表侧且与效果关联，则对其赋予攻击力上升500和等级上升1星的效果，直到其离场等标准重置时机。
function c13002461.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		-- 等级上升1星。
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end
