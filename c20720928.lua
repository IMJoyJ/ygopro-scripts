--メタファイズ・ファクター
-- 效果：
-- ①：只要这张卡在场地区域存在，自己在5星以上的「玄化」怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。这个效果适用召唤的怪兽在下个回合的结束阶段除外。
-- ②：只要这张卡在场地区域存在，对方不能对应自己的「玄化」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c20720928.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：①：只要这张卡在场地区域存在，自己在5星以上的「玄化」怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。这个效果适用召唤的怪兽在下个回合的结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20720928,0))  --"使用「玄化因子」效果不用解放召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCountLimit(1)
	e2:SetCondition(c20720928.ntcon)
	e2:SetTarget(c20720928.nttg)
	e2:SetOperation(c20720928.ntop)
	c:RegisterEffect(e2)
	-- 效果原文：②：只要这张卡在场地区域存在，对方不能对应自己的「玄化」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(c20720928.chainop)
	c:RegisterEffect(e3)
end
-- 判断召唤条件：当召唤的怪兽等级不低于5星且为「玄化」卡族时，允许不支付召唤所需解放。
function c20720928.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤条件：当召唤的怪兽等级不低于5星且为「玄化」卡族时，允许不支付召唤所需解放。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断召唤目标：召唤的怪兽等级不低于5星且为「玄化」卡族。
function c20720928.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x105)
end
-- 执行召唤操作：为召唤的怪兽注册标记，并设置在下个回合结束时除外的效果。
function c20720928.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	c:RegisterFlagEffect(20720928,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(20720928,1))  --"使用「玄化因子」效果召唤"
	-- 创建在下个回合结束时除外的持续效果。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置该效果在下个回合的结束阶段触发。
	e2:SetLabel(Duel.GetTurnCount()+1)
	e2:SetLabelObject(c)
	e2:SetCondition(c20720928.rmcon)
	e2:SetOperation(c20720928.rmop)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将该效果注册到游戏环境。
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否到回合结束阶段：若标记存在且当前回合数等于设定回合数，则触发除外效果。
function c20720928.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(20720928)~=0 then
		-- 判断是否到回合结束阶段：若标记存在且当前回合数等于设定回合数，则触发除外效果。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 执行除外操作：将标记的怪兽以正面表示形式除外。
function c20720928.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 执行除外操作：将标记的怪兽以正面表示形式除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 连锁限制操作：当对方发动「玄化」怪兽效果时，禁止其连锁发动魔法·陷阱·怪兽效果。
function c20720928.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x105) and re:IsActiveType(TYPE_MONSTER) and ep==tp then
		-- 设置连锁限制：禁止对方对己方「玄化」怪兽效果的发动进行连锁。
		Duel.SetChainLimit(c20720928.chainlm)
	end
end
-- 连锁限制条件：仅允许发动者自己进行连锁。
function c20720928.chainlm(e,rp,tp)
	return tp==rp
end
