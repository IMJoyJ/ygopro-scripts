--古代の機械砲台
-- 效果：
-- 把这张卡作祭品。给与对方基本分500分的伤害，这个回合的战斗阶段中双方不能发动陷阱卡。
function c80045583.initial_effect(c)
	-- 把这张卡作祭品。给与对方基本分500分的伤害，这个回合的战斗阶段中双方不能发动陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80045583,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c80045583.damcost)
	e1:SetTarget(c80045583.damtg)
	e1:SetOperation(c80045583.damop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查自身是否可以解放，并解放自身
function c80045583.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义发动准备：设置给与对方500点伤害的操作信息
function c80045583.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置给与对方玩家500点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 定义效果处理：给与对方500点伤害，并注册「战斗阶段双方不能发动陷阱卡」的效果
function c80045583.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方500点伤害，若实际伤害不等于500则结束处理
	if Duel.Damage(1-tp,500,REASON_EFFECT)~=500 then return end
	-- 这个回合的战斗阶段中双方不能发动陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetCondition(c80045583.accon)
	e1:SetValue(c80045583.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义效果生效条件：判断当前是否为战斗阶段
function c80045583.accon(e)
	-- 通过位运算判断当前阶段是否属于战斗阶段
	return bit.band(Duel.GetCurrentPhase(),0x38)~=0
end
-- 定义限制发动的卡片类型：限制陷阱卡的发动
function c80045583.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
