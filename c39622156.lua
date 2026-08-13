--No.26 次元孔路オクトバイパス
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的战斗阶段开始时，把这张卡1个超量素材取除才能发动。这次战斗阶段中，只能用1只怪兽攻击，那只怪兽的攻击变成直接攻击。
-- ②：怪兽直接攻击给与战斗伤害的伤害步骤结束时发动。那只攻击的怪兽的控制权移给从回合玩家来看的对方。
function c39622156.initial_effect(c)
	-- 给此卡添加XYZ召唤手续：用任意3星怪兽2只叠放（对应效果原文‘3星怪兽×2’）。
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
-- 将此卡的No.编号登记为26，用于识别数字卡编号（No.26）。
aux.xyz_number[39622156]=26
-- ①效果的发动代价：检查能否取除这张卡1个超量素材，能则取除作为发动COST。
function c39622156.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的处理：为本次战斗阶段注册‘只能1只怪兽攻击’的限制，并通过记录首次攻击的怪兽，使那只怪兽的攻击变为直接攻击。
function c39622156.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- “这次战斗阶段中，只能用1只怪兽攻击”。（创建限制攻击宣言的效果e1，并用e2记录首次攻击的怪兽）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c39622156.atkcon)
	e1:SetTarget(c39622156.atktg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 将‘只能1只怪兽攻击’的限制效果e1注册到场上，持续到战斗阶段结束。
	Duel.RegisterEffect(e1,tp)
	-- “那只怪兽的攻击变成直接攻击”。（创建攻击宣言记录效果e2及禁止其他怪兽成为攻击对象的效果e3，使首次攻击的怪兽只能直接攻击）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(c39622156.checkop)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 注册攻击宣言记录辅助效果e2，用于在战斗阶段中捕获第一次攻击宣言的怪兽。
	Duel.RegisterEffect(e2,tp)
	-- 对应①中“那只怪兽的攻击变成直接攻击”以及②整段效果：②：怪兽直接攻击给与战斗伤害的伤害步骤结束时发动。那只攻击的怪兽的控制权移给从回合玩家来看的对方。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(c39622156.imval)
	e3:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 注册e3：使其他怪兽不能成为攻击对象，从而让已记录的怪兽只能直接攻击。
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetProperty(0)
	e4:SetValue(0)
	-- 注册e3的副本e4，作为免疫判定参照，使原本不受效果影响的怪兽不会被e3的错误限制所影响。
	Duel.RegisterEffect(e4,tp)
	e3:SetLabelObject(e4)
end
-- 判定怪兽是否受e3影响：若怪兽不免疫参照效果e4则禁止其成为攻击对象；若免疫则不受限制。
function c39622156.imval(e,c)
	return not c:IsImmuneToEffect(e:GetLabelObject())
end
-- e1的限制条件：只有当前玩家已获得39622156标志（即已经标记了唯一可攻击的怪兽）时，才限制其他怪兽攻击。
function c39622156.atkcon(e)
	-- 检查当前玩家是否存在39622156标志，即是否本战斗阶段已经确定了那只可以攻击的怪兽。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),39622156)~=0
end
-- e1的攻击限制目标：攻击宣言的怪兽的FieldID不等于记录的FieldID时，不能攻击。
function c39622156.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 攻击宣言时记录第一只攻击怪兽：若尚未记录过，则保存其FieldID并设置标志，同时更新e1的标签。
function c39622156.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本战斗阶段已记录过攻击怪兽，则直接返回，不重复记录，确保只有第一只攻击的怪兽被允许攻击。
	if Duel.GetFlagEffect(tp,39622156)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 给当前玩家注册39622156标志，持续到战斗阶段结束，表示已确定本次战斗阶段允许攻击的怪兽。
	Duel.RegisterFlagEffect(tp,39622156,RESET_PHASE+PHASE_BATTLE,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- ②效果的发动条件：直接攻击造成战斗伤害的伤害步骤结束时发动（此处判定为直接攻击）。
function c39622156.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击目标是否为nil，即本次攻击是否为直接攻击。
	return Duel.GetAttackTarget()==nil
end
-- ②效果处理：把直接攻击的那只怪兽的控制权移给从回合玩家来看的对方。
function c39622156.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取正在攻击的怪兽（即直接攻击并造成伤害的那只怪兽）。
	local tc=Duel.GetAttacker()
	-- 获取当前回合玩家，用于确定控制权转移方向（从回合玩家到对方）。
	local p=Duel.GetTurnPlayer()
	-- 将攻击怪兽的控制权交给1-p（即回合玩家的对方）。
	Duel.GetControl(tc,1-p)
end
