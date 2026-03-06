--ファーニマル・キャット
-- 效果：
-- 「毛绒动物·猫」的效果1回合只能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
function c2729285.initial_effect(c)
	-- 创建效果，设置为单体诱发选发效果，具有取对象和延迟处理属性，触发时机为作为融合召唤的素材被送去墓地，限制1回合1次使用，条件为效果发动时卡片在墓地且因融合召唤被送去墓地，目标为己方墓地1张「融合」卡，效果为将该卡加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2729285,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,2729285)
	e1:SetCondition(c2729285.condition)
	e1:SetTarget(c2729285.target)
	e1:SetOperation(c2729285.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：卡片在墓地且因融合召唤被送去墓地
function c2729285.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end
-- 过滤器函数：筛选卡号为24094653（融合）且能加入手牌的卡片
function c2729285.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 设置效果的目标选择函数：当选择目标时，筛选己方墓地的「融合」卡，若无满足条件的卡则无法发动效果，选择后设置操作信息为将目标卡加入手牌
function c2729285.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2729285.filter(chkc) end
	-- 检查阶段：确认己方墓地是否存在满足条件的「融合」卡
	if chk==0 then return Duel.IsExistingTarget(c2729285.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张己方墓地的「融合」卡作为效果对象
	local g=Duel.SelectTarget(tp,c2729285.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：获取选择的目标卡，若目标卡仍存在于场上或墓地则将其加入手牌
function c2729285.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
