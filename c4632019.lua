--ヤマタコオロチ
-- 效果：
-- ①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作8星使用。
-- ②：这张卡为同调素材的同调怪兽得到那自身原本等级的以下效果。
-- ●8星以下：这张卡的攻击力·守备力上升800。
-- ●9星以上：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c4632019.initial_effect(c)
	-- ①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作8星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c4632019.synclv)
	c:RegisterEffect(e1)
	-- ②：这张卡为同调素材的同调怪兽得到那自身原本等级的以下效果。●8星以下：这张卡的攻击力·守备力上升800。●9星以上：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c4632019.efcon)
	e2:SetOperation(c4632019.efop)
	c:RegisterEffect(e2)
end
-- 作为同调素材时，将这张卡的等级视为8星（通过特殊编码值向系统提供同调素材等级，高16位为8，低16位保留原等级）。
function c4632019.synclv(e,c)
	-- 获取这张卡当前的等级（限制在系统上限内），作为原等级部分用于与8星组合成同调素材等级。
	local lv=aux.GetCappedLevel(e:GetHandler())
	return (8<<16)+lv
end
-- 判定这张卡是否作为同调召唤的素材被使用（原因必须为REASON_SYNCHRO），是则触发后续给同调怪兽赋予效果的处理。
function c4632019.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 作为同调素材被使用后，取出对应的同调怪兽，根据其原本等级执行对应强化：8星以下攻击力/守备力上升800；9星以上获得贯穿伤害；若该怪兽不是效果怪兽则补加效果怪兽类型。
function c4632019.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local lv=rc:GetOriginalLevel()
	local reg=nil
	if lv>0 and lv<=8 then
		-- ●8星以下：这张卡的攻击力·守备力上升800。
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
		-- ●9星以上：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
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
			-- 得到那自身原本等级的以下效果（为让非效果怪兽的同调怪兽也能适用所得效果，补加效果怪兽类型）。
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_ADD_TYPE)
			e0:SetValue(TYPE_EFFECT)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e0,true)
		end
	end
end
