--螺旋蘇生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只7星以下的龙族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把「龙骑士 盖亚」特殊召唤的场合，那只怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
function c56461575.initial_effect(c)
	-- 注册卡片脚本中关联的卡片密码（「龙骑士 盖亚」）。
	aux.AddCodeList(c,66889139)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只7星以下的龙族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把「龙骑士 盖亚」特殊召唤的场合，那只怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,56461575+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c56461575.target)
	e1:SetOperation(c56461575.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地等级7以下的龙族怪兽，且可以特殊召唤。
function c56461575.filter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的靶向检测，包含对已选择对象的重检测和发动条件的初步检测。
function c56461575.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56461575.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingTarget(c56461575.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c56461575.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤该对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数，处理特殊召唤以及「龙骑士 盖亚」的抗性赋予。
function c56461575.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其特殊召唤，并判断特殊召唤成功且该怪兽是「龙骑士 盖亚」。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsCode(66889139) then
		-- 那只怪兽不会成为对方的效果的对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c56461575.tgval)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1,true)
		-- 不会被对方的效果破坏
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(56461575,0))  --"「螺旋苏生」效果适用中"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c56461575.tgval)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2,true)
	end
end
-- 判定效果的控制者是否为对方玩家（用于抗性判定）。
function c56461575.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
