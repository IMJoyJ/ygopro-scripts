--エクシーズ・テリトリー
-- 效果：
-- 只在超量怪兽和怪兽进行战斗的伤害计算时，那些超量怪兽的攻击力·守备力上升那个阶级×200的数值。场上的这张卡被卡的效果破坏的场合，可以作为代替把自己场上1个超量素材取除。
function c4545854.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只在超量怪兽和怪兽进行战斗的伤害计算时，那些超量怪兽的攻击力·守备力上升那个阶级×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c4545854.adcon)
	e2:SetTarget(c4545854.adtg)
	e2:SetValue(c4545854.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 场上的这张卡被卡的效果破坏的场合，可以作为代替把自己场上1个超量素材取除。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c4545854.desreptg)
	c:RegisterEffect(e4)
end
-- 定义攻击力上升效果的发动条件：仅在伤害计算阶段且存在攻击对象（即战斗伤害计算中）时生效。
function c4545854.adcon(e)
	-- 判断当前阶段是否为伤害计算阶段，并确认存在被攻击的怪兽，以保证处于怪兽之间的战斗伤害计算时。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 指定攻击力上升效果的适用对象：当前战斗中的攻击怪兽或被攻击怪兽，且该怪兽必须是超量怪兽。
function c4545854.adtg(e,c)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	return (c==a or c==d) and c:IsType(TYPE_XYZ)
end
-- 计算攻击力/守备力的上升数值，为对象怪兽的阶级×200。
function c4545854.adval(e,c)
	return c:GetRank()*200
end
-- 代替破坏效果的判定函数：检查这张卡是否将要因卡的效果被破坏，且并非由代替破坏导致，并确认自己场上存在可移除的超量素材。
function c4545854.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE)
		-- 检查自己能否以效果原因从场上移除至少1个超量素材，用于代替这张卡的破坏。
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	-- 询问这张卡的持有者是否发动代替破坏效果，选择移除超量素材来保全这张卡。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 实际从自己场上移除1个超量素材，作为这张卡代替破坏的代价。
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)
		return true
	else return false end
end
