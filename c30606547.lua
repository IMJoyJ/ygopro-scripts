--暗黒の扉
-- 效果：
-- ①：双方玩家在战斗阶段只能用1只怪兽攻击。
function c30606547.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家在战斗阶段只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c30606547.atkcon)
	e2:SetTarget(c30606547.atktg)
	c:RegisterEffect(e2)
	-- ①：双方玩家在战斗阶段只能用1只怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c30606547.checkop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判定条件：本卡已记录过首次攻击宣言（拥有30606547标志）时，限制效果才适用。
function c30606547.atkcon(e)
	return e:GetHandler():GetFlagEffect(30606547)~=0
end
-- 限制对象：当攻击宣言怪兽的FieldID不是已记录的首次攻击怪兽的FieldID时，该怪兽不能攻击宣言。
function c30606547.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 记录首次攻击宣言：若本卡尚未记录，则取得第一只攻击宣言怪兽的FieldID，将其写入限制效果的Label，并为本卡添加直到结束阶段重置的标志，使后续攻击宣言被禁止。
function c30606547.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(30606547)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(30606547,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
