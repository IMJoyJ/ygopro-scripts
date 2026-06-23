--召喚獣カリギュラ
-- 效果：
-- 「召唤师 阿莱斯特」＋暗属性怪兽
-- ①：只要这张卡在怪兽区域存在，那个期间双方在1回合只能有1次把怪兽的效果发动，在同1次的战斗阶段中只能用1只怪兽攻击。
function c13529466.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为86120751的怪兽和1个暗属性怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,true,true)
	-- 只要这张卡在怪兽区域存在，那个期间双方在1回合只能有1次把怪兽的效果发动
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
	-- 在同1次的战斗阶段中只能用1只怪兽攻击
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
	-- ①：只要这张卡在怪兽区域存在，那个期间双方在1回合只能有1次把怪兽的效果发动，在同1次的战斗阶段中只能用1只怪兽攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetCondition(c13529466.atkcon)
	e7:SetTarget(c13529466.atktg)
	c:RegisterEffect(e7)
	-- ①：只要这张卡在怪兽区域存在，那个期间双方在1回合只能有1次把怪兽的效果发动，在同1次的战斗阶段中只能用1只怪兽攻击。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetOperation(c13529466.checkop)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
end
-- 记录我方怪兽效果发动次数
function c13529466.scount(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(13529466,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否已记录我方怪兽效果发动次数
function c13529466.econ1(e)
	return e:GetHandler():GetFlagEffect(13529466)~=0
end
-- 记录对方怪兽效果发动次数
function c13529466.ocount(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(13529467,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否已记录对方怪兽效果发动次数
function c13529466.econ2(e)
	return e:GetHandler():GetFlagEffect(13529467)~=0
end
-- 限制对方不能发动怪兽效果
function c13529466.elimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断是否已记录攻击阶段
function c13529466.atkcon(e)
	return e:GetHandler():GetFlagEffect(13529468)~=0
end
-- 限制攻击宣言
function c13529466.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 记录攻击怪兽的FieldID
function c13529466.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(13529468)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(13529468,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
