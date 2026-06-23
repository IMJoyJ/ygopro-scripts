--電子光虫－コクーンデンサ
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
-- ①：1回合1次，这张卡在场上攻击表示存在的场合，以自己墓地1只昆虫族·3星怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽守备表示特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡向守备表示怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c32465539.initial_effect(c)
	-- ①：1回合1次，这张卡在场上攻击表示存在的场合，以自己墓地1只昆虫族·3星怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽守备表示特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c32465539.xyzlimit)
	c:RegisterEffect(e0)
	-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32465539,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c32465539.spcon)
	e1:SetTarget(c32465539.sptg)
	e1:SetOperation(c32465539.spop)
	c:RegisterEffect(e1)
	-- 场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c32465539.efcon)
	e2:SetOperation(c32465539.efop)
	c:RegisterEffect(e2)
end
-- 当作为超量素材的卡不是昆虫族时，不能进行超量召唤。
function c32465539.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
-- 效果发动时，自身必须处于攻击表示。
function c32465539.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 检索满足条件的墓地昆虫族3星怪兽。
function c32465539.spfil(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足特殊召唤的条件。
function c32465539.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c32465539.spfil(chkc,e,tp) end
	-- 判断场上是否有足够的召唤空间。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c32465539.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标。
	local g=Duel.SelectTarget(tp,c32465539.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果，将目标怪兽特殊召唤。
function c32465539.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() then return end
	-- 将自身变为守备表示。
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	-- 判断场上是否有召唤空间。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断是否为超量召唤的素材。
function c32465539.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 处理超量召唤后的效果，为怪兽添加攻击时的限制效果。
function c32465539.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 当攻击宣言时，若攻击对象为守备表示怪兽，则记录标记。
	local e0=Effect.CreateEffect(rc)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c32465539.regop)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e0,true)
	-- 设置对方不能发动魔法·陷阱·怪兽效果的限制。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(32465539,1))  --"「电子光虫-电容茧」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c32465539.actcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若怪兽没有效果类型，则添加效果类型。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 记录攻击对象为守备表示怪兽的标记。
function c32465539.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsDefensePos() then
		c:RegisterFlagEffect(32465539,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 判断是否满足发动限制条件。
function c32465539.actcon(e)
	local c=e:GetHandler()
	-- 判断当前攻击的怪兽是否为自身且标记存在。
	return Duel.GetAttacker()==c and c:GetFlagEffect(32465539)>0
end
