--墓守の祈祷師
-- 效果：
-- 这张卡的守备力上升自己墓地的名字带有「守墓」的怪兽数量×200的数值。只要这张卡在场上表侧表示存在，名字带有「守墓」的怪兽以外的墓地发动的效果怪兽的效果无效化。此外，「王家长眠之谷」在场上存在的场合，对方不能把场地魔法卡发动，场地魔法卡不会被对方的效果破坏。
function c58139128.initial_effect(c)
	-- 这张卡的守备力上升自己墓地的名字带有「守墓」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c58139128.defval)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，名字带有「守墓」的怪兽以外的墓地发动的效果怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c58139128.disop)
	c:RegisterEffect(e2)
	-- 此外，「王家长眠之谷」在场上存在的场合，对方不能把场地魔法卡发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c58139128.econ)
	e3:SetValue(c58139128.efilter1)
	c:RegisterEffect(e3)
	-- 此外，「王家长眠之谷」在场上存在的场合，... 场地魔法卡不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCondition(c58139128.econ)
	e4:SetTarget(c58139128.etarget)
	e4:SetValue(c58139128.efilter2)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地中名字带有「守墓」的怪兽卡
function c58139128.filter(c)
	return c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER)
end
-- 计算守备力上升数值的函数
function c58139128.defval(e,c)
	-- 返回自己墓地中名字带有「守墓」的怪兽数量乘以200的数值
	return Duel.GetMatchingGroupCount(c58139128.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*200
end
-- 在连锁处理时无效非「守墓」怪兽在墓地发动的效果
function c58139128.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsSetCard(0x2e) and loc==LOCATION_GRAVE then
		-- 无效该连锁的效果
		Duel.NegateEffect(ev)
	end
end
-- 判断「王家长眠之谷」是否在场上存在的条件函数
function c58139128.econ(e)
	-- 检查当前生效的场地卡是否是「王家长眠之谷」（卡号：47355498）
	return Duel.IsEnvironment(47355498)
end
-- 限制发动的卡片过滤器，匹配场地魔法卡的发动
function c58139128.efilter1(e,re,tp)
	return re:GetHandler():IsType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 保护效果的目标过滤器，匹配场地魔法卡
function c58139128.etarget(e,c)
	return c:IsType(TYPE_FIELD)
end
-- 破坏效果的过滤器，匹配对方玩家的效果
function c58139128.efilter2(e,re,tp)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
