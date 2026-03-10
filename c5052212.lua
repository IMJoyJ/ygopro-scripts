--イージーチューニング
-- 效果：
-- ①：从自己墓地把1只调整除外，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力上升因为这张卡发动而除外的调整的攻击力数值。
function c5052212.initial_effect(c)
	-- 创建效果对象，设置为魔法卡发动效果，具有改变攻击力的Category属性，允许在伤害步骤发动，且只能在自由连锁时发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果只能在非伤害计算阶段或伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c5052212.cost)
	e1:SetTarget(c5052212.target)
	e1:SetOperation(c5052212.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断是否为调整类型且可作为除外的代价
function c5052212.cfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 效果的费用处理函数：检查墓地是否存在调整并选择除外，将调整的攻击力设为标签值
function c5052212.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件：墓地存在至少1只调整
	if chk==0 then return Duel.IsExistingMatchingCard(c5052212.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只调整作为除外对象
	local g=Duel.SelectMatchingCard(tp,c5052212.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 将选中的调整以正面表示形式除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标选择函数：选择自己场上1只表侧表示怪兽作为目标
function c5052212.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否满足目标条件：自己场上存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动处理函数：为选定的目标怪兽增加攻击力
function c5052212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为该怪兽创建一个攻击力变更效果，数值等于发动时除外调整的攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(e:GetLabel())
		tc:RegisterEffect(e1)
	end
end
