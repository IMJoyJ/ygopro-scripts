--LL－サファイア・スワロー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有鸟兽族怪兽存在的场合才能发动。这张卡和1只鸟兽族·1星怪兽从手卡特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
-- ●这次超量召唤成功的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
function c60954556.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有鸟兽族怪兽存在的场合才能发动。这张卡和1只鸟兽族·1星怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60954556,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,60954556)
	e1:SetCondition(c60954556.spcon)
	e1:SetTarget(c60954556.sptg)
	e1:SetOperation(c60954556.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c60954556.efcon)
	e2:SetOperation(c60954556.efop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的鸟兽族怪兽
function c60954556.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST)
end
-- ①号效果的发动条件：自己场上有鸟兽族怪兽存在
function c60954556.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的鸟兽族怪兽
	return Duel.IsExistingMatchingCard(c60954556.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡中可以特殊召唤的1星鸟兽族怪兽
function c60954556.spfilter(c,e,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与合法性检测（包含怪兽区域空格数、青眼精灵龙限制、自身及手卡另一只怪兽的特召检测）
function c60954556.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡中是否存在除自身以外可以特殊召唤的1星鸟兽族怪兽
		and Duel.IsExistingMatchingCard(c60954556.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 设置操作信息：从手卡特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①号效果的效果处理：从手卡将自身和另一只1星鸟兽族怪兽特殊召唤
function c60954556.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只除自身以外的1星鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c60954556.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选中的怪兽和自身特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果赋予条件：作为风属性怪兽的超量素材
function c60954556.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- ②号效果赋予处理：为超量召唤的风属性怪兽注册并赋予新效果，若其不是效果怪兽则为其添加“效果怪兽”类型
function c60954556.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(60954556,1))  --"补充超量素材（抒情歌鸲-青玉燕）"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c60954556.xyzcon)
	e1:SetTarget(c60954556.xyztg)
	e1:SetOperation(c60954556.xyzop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这次超量召唤成功的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 赋予效果的发动条件：该怪兽超量召唤成功
function c60954556.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤条件：墓地中可以作为超量素材的「抒情歌鸲」怪兽
function c60954556.xyzfilter(c)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 赋予效果的发动准备：选择自己墓地1只「抒情歌鸲」怪兽作为对象
function c60954556.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c60954556.xyzfilter(chkc) end
	-- 检查自己墓地是否存在可以作为超量素材的「抒情歌鸲」怪兽
	if chk==0 then return Duel.IsExistingTarget(c60954556.xyzfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地1只「抒情歌鸲」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60954556.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：墓地的卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 赋予效果的效果处理：将选中的墓地怪兽重叠作为该怪兽的超量素材
function c60954556.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠作为该怪兽的超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
