--No.26 次元孔路オクトバイパス
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的战斗阶段开始时，把这张卡1个超量素材取除才能发动。这次战斗阶段中，只能用1只怪兽攻击，那只怪兽的攻击变成直接攻击。
-- ②：怪兽直接攻击给与战斗伤害的伤害步骤结束时发动。那只攻击的怪兽的控制权移给从回合玩家来看的对方。
function c39622156.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为3的怪兽2只进行叠放
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：自己·对方的战斗阶段开始时，把这张卡1个超量素材取除才能发动。这次战斗阶段中，只能用1只怪兽攻击，那只怪兽的攻击变成直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39622156,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,39622156)
	e1:SetCost(c39622156.dacost)
	e1:SetOperation(c39622156.daop)
	c:RegisterEffect(e1)
	-- ②：怪兽直接攻击给与战斗伤害的伤害步骤结束时发动。那只攻击的怪兽的控制权移给从回合玩家来看的对方。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39622156,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c39622156.condition)
	e2:SetOperation(c39622156.operation)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为26
aux.xyz_number[39622156]=26
-- 支付效果代价，从场上移除1个超量素材
function c39622156.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动，使本次战斗阶段只能用1只怪兽攻击，且该怪兽攻击变为直接攻击
function c39622156.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使本次战斗阶段中，除了被指定的怪兽外，其他怪兽不能进行攻击宣言
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c39622156.atkcon)
	e1:SetTarget(c39622156.atktg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 注册效果，使该效果生效
	Duel.RegisterEffect(e1,tp)
	-- 注册持续效果，用于记录攻击怪兽的FieldID
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(c39622156.checkop)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 注册效果，使该效果生效
	Duel.RegisterEffect(e2,tp)
	-- 使本次战斗阶段中，被指定的怪兽不能成为攻击对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(c39622156.imval)
	e3:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 注册效果，使该效果生效
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetProperty(0)
	e4:SetValue(0)
	-- 注册效果，使该效果生效
	Duel.RegisterEffect(e4,tp)
	e3:SetLabelObject(e4)
end
-- 返回目标怪兽是否免疫当前效果
function c39622156.imval(e,c)
	return not c:IsImmuneToEffect(e:GetLabelObject())
end
-- 判断是否已使用过效果①
function c39622156.atkcon(e)
	-- 判断是否已使用过效果①
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),39622156)~=0
end
-- 判断目标怪兽是否为被指定的怪兽
function c39622156.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 记录攻击怪兽的FieldID并注册标识效果
function c39622156.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已使用过效果①
	if Duel.GetFlagEffect(tp,39622156)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 注册标识效果，标记效果①已使用
	Duel.RegisterFlagEffect(tp,39622156,RESET_PHASE+PHASE_BATTLE,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 判断是否为直接攻击
function c39622156.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为直接攻击
	return Duel.GetAttackTarget()==nil
end
-- 效果发动，将攻击怪兽的控制权转移给对方
function c39622156.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	-- 将攻击怪兽的控制权转移给对方
	Duel.GetControl(tc,1-p)
end
