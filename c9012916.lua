--ブラックフェザー・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：自己受到效果伤害的场合，作为代替给这张卡放置1个黑羽指示物。
-- ②：这张卡的攻击力下降这张卡的黑羽指示物数量×700。
-- ③：1回合1次，把这张卡的黑羽指示物全部取除，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力下降取除的黑羽指示物数量×700，给与对方下降数值的伤害。
function c9012916.initial_effect(c)
	c:EnableCounterPermit(0x10)
	-- 为这张卡添加同调召唤手续（需要1只调整和1只以上调整以外的怪兽）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己受到效果伤害的场合，作为代替给这张卡放置1个黑羽指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REPLACE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c9012916.damval)
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e4)
	-- ②：这张卡的攻击力下降这张卡的黑羽指示物数量×700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c9012916.atkval)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡的黑羽指示物全部取除，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力下降取除的黑羽指示物数量×700，给与对方下降数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9012916,0))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c9012916.cost)
	e3:SetTarget(c9012916.target)
	e3:SetOperation(c9012916.operation)
	c:RegisterEffect(e3)
end
-- 代替伤害的价值函数，若受到的是效果伤害，则在自身放置1个黑羽指示物，并将受到的伤害变为0。
function c9012916.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then
		e:GetHandler():AddCounter(0x10,1)
		return 0
	end
	return val
end
-- 计算并返回这张卡因黑羽指示物数量而下降的攻击力数值。
function c9012916.atkval(e,c)
	return c:GetCounter(0x10)*-700
end
-- 效果③的代价处理：检查并取除自身所有的黑羽指示物，并将取除数量×700的数值记录在效果中。
function c9012916.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x10)>0 end
	local ct=e:GetHandler():GetCounter(0x10)
	e:SetLabel(ct*700)
	e:GetHandler():RemoveCounter(tp,0x10,ct,REASON_COST)
end
-- 效果③的对象选择与发动条件判定：选择对方场上1只表侧表示且攻击力大于0的怪兽作为对象。
function c9012916.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在发动时，检查对方场上是否存在可以作为对象的表侧表示且攻击力大于0的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示且攻击力大于0的怪兽作为效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果③的效果处理：使作为对象的怪兽攻击力下降，并给与对方实际下降数值的伤害。
function c9012916.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local val=e:GetLabel()
		local atk=tc:GetAttack()
		-- 那只对方怪兽的攻击力下降取除的黑羽指示物数量×700
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		tc:RegisterEffect(e1)
		-- 如果下降数值大于该怪兽当前的攻击力，则给与对方该怪兽当前攻击力数值的伤害（实际下降数值为当前攻击力）。
		if val>atk then Duel.Damage(1-tp,atk,REASON_EFFECT)
		-- 否则，给与对方该下降数值的伤害。
		else Duel.Damage(1-tp,val,REASON_EFFECT) end
	end
end
