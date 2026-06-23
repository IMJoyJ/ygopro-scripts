--BF－アンカー
-- 效果：
-- 把1只名字带有「黑羽」的怪兽解放，选择自己场上表侧表示存在的1只同调怪兽发动。选择的怪兽的攻击力直到结束阶段时上升为把这张卡发动而解放的怪兽的攻击力数值。
function c25435080.initial_effect(c)
	-- 创建效果对象，设置为发动效果，具有改变攻击力、伤害步骤发动、取对象效果属性，自由连锁时点，伤害步骤提示，发动条件为伤害阶段前，消耗函数为cost，目标函数为target，发动函数为activate，标签初始为0
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c25435080.cost)
	e1:SetTarget(c25435080.target)
	e1:SetOperation(c25435080.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断场上是否存在名字带有黑羽的怪兽且存在可选择的同调怪兽
function c25435080.cfilter(c,tp)
	-- 名字带有黑羽且场上存在可选择的同调怪兽
	return c:IsSetCard(0x33) and Duel.IsExistingTarget(c25435080.tfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤函数，判断是否为表侧表示的同调怪兽
function c25435080.tfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 设置标签为1，表示已支付代价
function c25435080.cost(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	return true
end
-- 设置效果目标，检查是否满足条件，若满足则选择解放名字带有黑羽的怪兽并释放，再选择场上表侧表示的同调怪兽作为目标
function c25435080.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c25435080.tfilter(chkc) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的可解放怪兽
		return Duel.CheckReleaseGroup(tp,c25435080.cfilter,1,nil,tp)
	end
	-- 选择一张满足条件的可解放怪兽
	local rg=Duel.SelectReleaseGroup(tp,c25435080.cfilter,1,1,nil,tp)
	e:SetLabel(rg:GetFirst():GetAttack())
	-- 以代价原因解放选择的怪兽
	Duel.Release(rg,REASON_COST)
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的同调怪兽作为目标
	Duel.SelectTarget(tp,c25435080.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果，为选择的目标怪兽增加攻击力
function c25435080.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为选择的怪兽增加攻击力，数值为解放怪兽的攻击力，直到结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
