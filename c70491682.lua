--ヴェンデット・アニマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把墓地的这张卡除外，以「复仇死者·阿尼玛」以外的除外的1只自己的「复仇死者」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
-- ●这张卡战斗破坏的怪兽不去墓地而除外。
function c70491682.initial_effect(c)
	-- ①：把墓地的这张卡除外，以「复仇死者·阿尼玛」以外的除外的1只自己的「复仇死者」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70491682,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,70491682)
	-- 把墓地的这张卡除外作为发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c70491682.sptg)
	e1:SetOperation(c70491682.spop)
	c:RegisterEffect(e1)
	-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,70491683)
	e2:SetCondition(c70491682.mtcon)
	e2:SetOperation(c70491682.mtop)
	c:RegisterEffect(e2)
end
-- 过滤除外区中除「复仇死者·阿尼玛」以外的表侧表示「复仇死者」怪兽
function c70491682.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x106) and not c:IsCode(70491682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空位、是否存在可特殊召唤的目标，并选择该目标）
function c70491682.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c70491682.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足条件的「复仇死者」怪兽
		and Duel.IsExistingTarget(c70491682.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择除外区1只满足条件的「复仇死者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70491682.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（包含目标卡片组和数量）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理（特殊召唤目标怪兽，并适用“直到回合结束时自己不是不死族怪兽不能特殊召唤”的限制）
function c70491682.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c70491682.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤不死族以外怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤不死族以外的怪兽
function c70491682.splimit(e,c)
	return c:GetRace()~=RACE_ZOMBIE
end
-- 检查是否作为仪式召唤的素材从场上送去墓地，且仪式召唤的怪兽是「复仇死者」怪兽
function c70491682.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- 给仪式召唤出的「复仇死者」怪兽赋予“战斗破坏的怪兽除外”的效果，并在其不是效果怪兽时追加效果怪兽类型
function c70491682.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- ●这张卡战斗破坏的怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡战斗破坏的怪兽不去墓地而除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(70491682,1))  --"「复仇死者·阿尼玛」效果适用中"
end
