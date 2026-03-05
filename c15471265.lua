--バーサーカークラッシュ
-- 效果：
-- 把自己墓地存在的1只怪兽从游戏中除外发动。直到这个回合的结束阶段时，自己场上表侧表示存在的1只「羽翼栗子球」的攻击力·守备力变成和除外怪兽相同数值。
function c15471265.initial_effect(c)
	-- 创建效果，设置效果类别为改变攻击力，类型为发动效果，属性为取对象效果和伤害步骤效果，时点为自由连锁，提示伤害步骤时点，条件为伤害步骤前发动，消耗函数为c15471265.cost，目标函数为c15471265.target，发动函数为c15471265.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为伤害步骤前，防止在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c15471265.cost)
	e1:SetTarget(c15471265.target)
	e1:SetOperation(c15471265.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选墓地中的怪兽卡并可作为除外代价
function c15471265.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的消耗函数，检查是否有满足条件的怪兽卡可除外，并选择一张除外
function c15471265.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即是否有满足条件的怪兽卡存在于墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c15471265.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽卡并返回选择结果
	local g=Duel.SelectMatchingCard(tp,c15471265.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的怪兽卡从游戏中除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选自己场上表侧表示的羽翼栗子球
function c15471265.filter(c)
	return c:IsFaceup() and c:IsCode(57116033)
end
-- 效果发动时的目标选择函数，选择自己场上表侧表示的羽翼栗子球
function c15471265.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15471265.filter(chkc) end
	-- 检查是否满足目标选择条件，即自己场上是否存在满足条件的羽翼栗子球
	if chk==0 then return Duel.IsExistingTarget(c15471265.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的羽翼栗子球作为目标
	local g=Duel.SelectTarget(tp,c15471265.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数，将目标怪兽的攻击力和守备力设置为除外怪兽的数值
function c15471265.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local rc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的攻击力设置为除外怪兽的攻击力数值，直到结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(rc:GetTextAttack())
		tc:RegisterEffect(e1)
		-- 将目标怪兽的守备力设置为除外怪兽的守备力数值，直到结束阶段重置
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(rc:GetTextDefense())
		tc:RegisterEffect(e2)
	end
end
