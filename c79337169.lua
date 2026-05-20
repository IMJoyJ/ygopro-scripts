--ガントレット・ウォリアー
-- 效果：
-- 把这张卡解放发动。自己场上表侧表示存在的全部战士族怪兽的攻击力·守备力上升500，直到那些怪兽进行战斗的伤害步骤结束时适用。这个效果在对方回合也能发动。
function c79337169.initial_effect(c)
	-- 把这张卡解放发动。自己场上表侧表示存在的全部战士族怪兽的攻击力·守备力上升500，直到那些怪兽进行战斗的伤害步骤结束时适用。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79337169,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为非伤害步骤，或伤害步骤的伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetCost(c79337169.cost)
	e1:SetTarget(c79337169.target)
	e1:SetOperation(c79337169.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查并解放自身
function c79337169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的战士族怪兽
function c79337169.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 定义发动目标：检查自己场上是否存在除自身以外的表侧表示战士族怪兽
function c79337169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只除自身以外的表侧表示战士族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79337169.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 定义效果处理：使自己场上所有表侧表示的战士族怪兽攻击力·守备力上升500，并注册在伤害步骤结束时重置该效果的辅助效果
function c79337169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上除自身以外的所有表侧表示战士族怪兽
	local g=Duel.GetMatchingGroup(c79337169.filter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 自己场上表侧表示存在的全部战士族怪兽的攻击力·守备力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetLabelObject(e1)
		tc:RegisterEffect(e2)
		-- 直到那些怪兽进行战斗的伤害步骤结束时适用。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetCondition(c79337169.resetcon)
		e3:SetOperation(c79337169.resetop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetLabelObject(e2)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
-- 重置效果的触发条件：该怪兽进行了战斗
function c79337169.resetcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 重置效果的处理：手动重置该怪兽的攻击力上升、守备力上升效果以及此重置效果自身
function c79337169.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	local e2=e1:GetLabelObject()
	e1:Reset()
	e2:Reset()
	e:Reset()
end
