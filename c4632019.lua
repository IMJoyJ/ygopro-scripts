--ヤマタコオロチ
-- 效果：
-- ①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作8星使用。
-- ②：这张卡为同调素材的同调怪兽得到那自身原本等级的以下效果。
-- ●8星以下：这张卡的攻击力·守备力上升800。
-- ●9星以上：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c4632019.initial_effect(c)
	-- 效果原文：①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作8星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c4632019.synclv)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡为同调素材的同调怪兽得到那自身原本等级的以下效果。●8星以下：这张卡的攻击力·守备力上升800。●9星以上：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c4632019.efcon)
	e2:SetOperation(c4632019.efop)
	c:RegisterEffect(e2)
end
-- 规则层面：将该卡的等级视为8星使用，用于同调召唤时的等级判定。
function c4632019.synclv(e,c)
	-- 规则层面：获取该卡当前等级（经过系统安全阈值处理）。
	local lv=aux.GetCappedLevel(e:GetHandler())
	return (8<<16)+lv
end
-- 规则层面：判断该卡是否因同调召唤而成为素材。
function c4632019.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 规则层面：根据同调怪兽的原本等级，为其附加攻击力上升、守备力上升或贯穿伤害效果，并确保其具有效果种类。
function c4632019.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local lv=rc:GetOriginalLevel()
	local reg=nil
	if lv>0 and lv<=8 then
		-- 效果原文：●8星以下：这张卡的攻击力·守备力上升800。
		local e1=Effect.CreateEffect(rc)
		e1:SetDescription(aux.Stringid(4632019,0))  --"「八蛸大蛇」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(800)
		rc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		rc:RegisterEffect(e2,true)
		reg=true
	elseif lv>=9 then
		-- 效果原文：●9星以上：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
		local e2=Effect.CreateEffect(rc)
		e2:SetDescription(aux.Stringid(4632019,0))  --"「八蛸大蛇」效果适用中"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
		reg=true
	end
	if reg then
		if not rc:IsType(TYPE_EFFECT) then
			-- 效果原文：这张卡为同调素材的同调怪兽得到那自身原本等级的以下效果。
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_ADD_TYPE)
			e0:SetValue(TYPE_EFFECT)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e0,true)
		end
	end
end
