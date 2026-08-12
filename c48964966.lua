--アテナ
-- 效果：
-- ①：1回合1次，把「雅典娜」以外的自己场上1只表侧表示的天使族怪兽送去墓地，以「雅典娜」以外的自己墓地1只天使族怪兽为对象才能发动。那只天使族怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
function c48964966.initial_effect(c)
	-- ①：1回合1次，把「雅典娜」以外的自己场上1只表侧表示的天使族怪兽送去墓地，以「雅典娜」以外的自己墓地1只天使族怪兽为对象才能发动。那只天使族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48964966,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c48964966.cost)
	e1:SetTarget(c48964966.target)
	e1:SetOperation(c48964966.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48964966,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c48964966.condition2)
	e2:SetTarget(c48964966.target2)
	e2:SetOperation(c48964966.operation2)
	c:RegisterEffect(e2)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48964966,1))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c48964966.condition2)
	e3:SetTarget(c48964966.target2)
	e3:SetOperation(c48964966.operation2)
	c:RegisterEffect(e3)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48964966,1))  --"伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e4:SetCondition(c48964966.condition2)
	e4:SetTarget(c48964966.target2)
	e4:SetOperation(c48964966.operation2)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上满足条件的天使族怪兽（非雅典娜且可作为墓地代价）
function c48964966.filter1(c,ft)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and not c:IsCode(48964966) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- 效果处理时的费用支付阶段，检查是否满足支付条件并选择要送去墓地的怪兽
function c48964966.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前场上可用的主怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足支付费用的条件（场上有可送墓的怪兽）
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c48964966.filter1,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽作为支付费用
	local g=Duel.SelectMatchingCard(tp,c48964966.filter1,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的怪兽送去墓地作为效果的费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于判断墓地中满足条件的天使族怪兽（非雅典娜且可特殊召唤）
function c48964966.filter2(c,e,sp)
	return c:IsRace(RACE_FAIRY) and not c:IsCode(48964966) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 设置效果的目标选择阶段，检查是否有满足条件的墓地怪兽可供选择
function c48964966.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48964966.filter2(chkc,e,tp) end
	-- 判断是否满足选择目标的条件（墓地有可特殊召唤的天使族怪兽）
	if chk==0 then return Duel.IsExistingTarget(c48964966.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果的目标
	local g=Duel.SelectTarget(tp,c48964966.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的怪兽数量和对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段，执行特殊召唤操作
function c48964966.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FAIRY) then
		-- 将目标怪兽以指定方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 触发条件判断函数，用于判断是否为非雅典娜的天使族怪兽召唤/反转/特殊召唤成功
function c48964966.condition2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:FilterCount(Card.IsRace,nil,RACE_FAIRY)>0
end
-- 设置伤害效果的目标和参数信息
function c48964966.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设定本次伤害效果的伤害值为600
	Duel.SetTargetParam(600)
	-- 设置本次效果的操作信息，包含将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 执行伤害效果处理阶段
function c48964966.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
