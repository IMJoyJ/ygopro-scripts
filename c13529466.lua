--召喚獣カリギュラ
-- 效果：
-- 「召唤师 阿莱斯特」＋暗属性怪兽
-- ①：只要这张卡在怪兽区域存在，那个期间双方在1回合只能有1次把怪兽的效果发动，在同1次的战斗阶段中只能用1只怪兽攻击。
function c13529466.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：以「召唤师 阿莱斯特」＋暗属性怪兽为融合素材（对应卡号86120751和1只暗属性怪兽）。
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,true,true)
	-- ①：只要这张卡在怪兽区域存在，那个期间双方在1回合只能有1次把怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c13529466.scount)
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetOperation(c13529466.ocount)
	c:RegisterEffect(e4)
	-- 双方在1回合只能有1次把怪兽的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c13529466.econ1)
	e3:SetValue(c13529466.elimit)
	c:RegisterEffect(e3)
	local e6=e3:Clone()
	e6:SetCondition(c13529466.econ2)
	e6:SetTargetRange(0,1)
	c:RegisterEffect(e6)
	-- 在同1次的战斗阶段中只能用1只怪兽攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetCondition(c13529466.atkcon)
	e7:SetTarget(c13529466.atktg)
	c:RegisterEffect(e7)
	-- 在同1次的战斗阶段中只能用1只怪兽攻击。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetOperation(c13529466.checkop)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
end
-- 当这张卡的控制者发动怪兽效果时，给这张卡设置标记13529466，用于记录己方在本回合已经发动过一次怪兽效果；若非己方发动或不是怪兽效果则不记录。
function c13529466.scount(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(13529466,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断条件：这张卡带有标记13529466时返回真，表示己方本回合已经发动过一次怪兽效果，此时禁止己方再发动怪兽效果。
function c13529466.econ1(e)
	return e:GetHandler():GetFlagEffect(13529466)~=0
end
-- 当对方玩家发动怪兽效果时，给这张卡设置标记13529467，用于记录对方在本回合已经发动过一次怪兽效果；若非对方发动或不是怪兽效果则不记录。
function c13529466.ocount(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(13529467,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断条件：这张卡带有标记13529467时返回真，表示对方本回合已经发动过一次怪兽效果，此时禁止对方再发动怪兽效果。
function c13529466.econ2(e)
	return e:GetHandler():GetFlagEffect(13529467)~=0
end
-- EFFECT_CANNOT_ACTIVATE的Value函数：如果试图发动的效果是怪兽效果则返回真，即禁止该效果发动。
function c13529466.elimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断条件：这张卡带有标记13529468时返回真，表示本回合已经有一次攻击宣言发生，此时开始限制其他怪兽不能进行攻击宣言。
function c13529466.atkcon(e)
	return e:GetHandler():GetFlagEffect(13529468)~=0
end
-- EFFECT_CANNOT_ATTACK_ANNOUNCE的Target函数：若怪兽的FieldID与记录的首次攻击宣言怪兽的FieldID不同，则不能进行攻击宣言，以此保证同一次战斗阶段只能有1只怪兽攻击。
function c13529466.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 攻击宣言时点的操作：若本回合尚未记录过攻击宣言，则记录本次攻击宣言的怪兽的FieldID到e7的Label，并给这张卡设置标记13529468，表示已经有过攻击宣言；之后其他怪兽的攻击宣言将被e7禁止。
function c13529466.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(13529468)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(13529468,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
