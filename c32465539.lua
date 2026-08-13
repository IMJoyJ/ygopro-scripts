--電子光虫－コクーンデンサ
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
-- ①：1回合1次，这张卡在场上攻击表示存在的场合，以自己墓地1只昆虫族·3星怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽守备表示特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡向守备表示怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c32465539.initial_effect(c)
	-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c32465539.xyzlimit)
	c:RegisterEffect(e0)
	-- ①：1回合1次，这张卡在场上攻击表示存在的场合，以自己墓地1只昆虫族·3星怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽守备表示特殊召唤。
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
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c32465539.efcon)
	e2:SetOperation(c32465539.efop)
	c:RegisterEffect(e2)
end
-- 限制超量素材：若素材怪兽不是昆虫族，则不能作为这张卡的超量召唤素材。
function c32465539.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
-- ①效果的发动条件：这张卡在场上以表侧攻击表示存在。
function c32465539.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 筛选符合条件的墓地怪兽：必须是昆虫族·3星，且能够被当前效果以表侧守备表示特殊召唤。
function c32465539.spfil(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 起动效果的目标处理：进行发动合法性检查，并让玩家选择自己墓地1只符合条件的昆虫族·3星怪兽作为对象。
function c32465539.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c32465539.spfil(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空位，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只符合条件的昆虫族·3星怪兽，作为发动条件之一。
		and Duel.IsExistingTarget(c32465539.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合过滤条件的昆虫族·3星怪兽，并将其设为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,c32465539.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，登记本次效果将进行1只怪兽的特殊召唤（处理时再实际召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的解决处理：将自身变为守备表示，并将对象怪兽从墓地守备表示特殊召唤；若自身已离场或已守备表示则不再处理。
function c32465539.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() then return end
	-- 将这张卡由攻击表示变为表侧守备表示。
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	-- 特殊召唤前检查自己主要怪兽区是否还有空位，若没有空位则中止特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取通过效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的触发条件：这张卡作为超量召唤的素材被使用（reason为超量召唤）。
function c32465539.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- ②效果的处理：给超量召唤成功的怪兽赋予下述效果——攻击守备表示怪兽时，对方不能发动魔法·陷阱·怪兽效果；若该怪兽不是效果怪兽，则先为其添加效果类型以保证效果适用。
function c32465539.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 这张卡向守备表示怪兽攻击的场合
	local e0=Effect.CreateEffect(rc)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c32465539.regop)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e0,true)
	-- 对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
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
		-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 攻击宣言时的辅助处理：记录该怪兽是否对守备表示怪兽进行了攻击，若攻击对象为守备表示则设置标记。
function c32465539.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsDefensePos() then
		c:RegisterFlagEffect(32465539,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 禁止发动效果的持续效果的适用条件：当前进行攻击宣言的怪兽正是获得了②效果的怪兽，且本回合战斗阶段内它攻击过守备表示怪兽。
function c32465539.actcon(e)
	local c=e:GetHandler()
	-- 具体判定条件：Duel.GetAttacker()返回的攻击怪兽是该效果处理怪兽，且它带有已攻击守备怪兽的标记。
	return Duel.GetAttacker()==c and c:GetFlagEffect(32465539)>0
end
