--M・HERO 光牙
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡的攻击力上升对方场上的怪兽数量×500。
-- ②：1回合1次，把自己墓地1只「英雄」怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降因为这个效果发动而除外的怪兽的攻击力数值。这个效果在对方回合也能发动。
function c50608164.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为 aux.MaskChangeLimit：只允许通过「假面变化」的效果进行特殊召唤，其他方式不能特殊召唤。
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升对方场上的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c50608164.val)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己墓地1只「英雄」怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降因为这个效果发动而除外的怪兽的攻击力数值。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50608164,0))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	-- 设置效果的发动条件为 aux.dscon：当前阶段不在伤害步骤，或虽在伤害步骤但尚未进行伤害计算；从而该效果在伤害步骤内只能在伤害计算前发动，且因为是诱发即时效果，在对方回合也能发动。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c50608164.cost)
	e3:SetTarget(c50608164.target)
	e3:SetOperation(c50608164.operation)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升数值的计算函数：以这张卡的控制者为视角，统计对方场上的怪兽区怪兽数量，并乘以500作为攻击力上升值。
function c50608164.val(e,c)
	-- 返回这张卡控制者对方场上的怪兽数量×500，作为永续攻击力上升的数值。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*500
end
-- 定义代价筛选条件：选择自己墓地中满足「英雄」字段（0x8）、是怪兽卡且可以作为代价除外的卡。
function c50608164.cfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义效果发动代价：检测并选择自己墓地1只符合条件的「英雄」怪兽除外，并将该怪兽的攻击力记录在效果的标签中，供后续处理时使用。
function c50608164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，检查自己墓地是否存在至少1只符合条件的「英雄」怪兽可以除外；若不存在则不能支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c50608164.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只符合条件的「英雄」怪兽，作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c50608164.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选择到的怪兽以表侧表示除外（REASON_COST），完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义效果对象的选择逻辑：选择场上1只表侧表示怪兽作为效果对象；包含对已指定对象合法性的验证、是否存在可选取对象的检查，以及将选择对象设为效果对象。
function c50608164.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动时检查场上是否存在至少1只表侧表示怪兽可以作为效果对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽，并将其设置为该效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理：取得对象怪兽，若它仍表侧表示且与发动效果关联，则赋予它一个攻击力下降效果，下降数值为效果发动时除外的怪兽的攻击力，持续到回合结束；该下降效果不能被无效。
function c50608164.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果发起时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时下降因为这个效果发动而除外的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
