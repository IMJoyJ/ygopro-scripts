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
-- 过滤函数，用于检查墓地是否满足条件的魔法卡
function c13002461.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
-- 支付效果代价时调用的函数
function c13002461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张名字带有「魔导书」的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13002461.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择1张满足条件的魔法卡返回卡组
	local g=Duel.SelectMatchingCard(tp,c13002461.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 显示被选中的卡
	Duel.HintSelection(g)
	-- 将选中的卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数，用于检查场上是否满足条件的魔法师族怪兽
function c13002461.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(1)
end
-- 选择效果对象时调用的函数
function c13002461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13002461.filter(chkc) end
	-- 检查场上是否存在至少1只魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c13002461.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择1只满足条件的魔法师族怪兽作为效果对象
	Duel.SelectTarget(tp,c13002461.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 发动效果时调用的函数
function c13002461.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		-- 选择的怪兽的等级上升1星
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end
