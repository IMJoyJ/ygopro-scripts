--OToNaRiサンダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有雷族怪兽2只以上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：以自己场上1只超量怪兽为对象才能发动。把包含场上的这张卡的自己的手卡·场上（表侧表示）·墓地2只雷族·光属性·4星怪兽作为成为对象的怪兽的超量素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡·墓地特召）和②效果（将自身及手卡·场上·墓地的雷族·光属性·4星怪兽作为场上超量怪兽的超量素材）。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有雷族怪兽2只以上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只超量怪兽为对象才能发动。把包含场上的这张卡的自己的手卡·场上（表侧表示）·墓地2只雷族·光属性·4星怪兽作为成为对象的怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.xtg)
	e2:SetOperation(s.xop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的雷族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- ①效果的发动条件：自己场上有2只以上的雷族怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的雷族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- ①效果的发动准备与合法性检查（检查怪兽区域空位及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：特殊召唤自身，并添加离场时除外的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：以自己场上1只超量怪兽为对象才能发动。把包含场上的这张卡的自己的手卡·场上（表侧表示）·墓地2只雷族·光属性·4星怪兽作为成为对象的怪兽的超量素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：自己场上表侧表示的超量怪兽。
function s.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 过滤条件：自己持有、表侧表示（若在场上）、等级4、光属性、雷族且可以作为超量素材的怪兽。
function s.xyzfilter(c,tp,e)
	return c:IsControler(tp) and c:IsFaceupEx() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_THUNDER) and c:IsCanOverlay() and not c:IsImmuneToEffect(e)
end
-- ②效果的发动准备与合法性检查（选择1只超量怪兽作为对象，并确认手卡·场上·墓地有足够的素材）。
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xfilter(chkc) and chkc~=c end
	-- 检查自己场上是否存在除自身以外的表侧表示超量怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.xfilter,tp,LOCATION_MZONE,0,1,c)
		-- 检查自身是否满足素材条件，且手卡·场上·墓地是否存在至少1只除自身以外的满足条件的雷族·光属性·4星怪兽。
		and s.xyzfilter(c,tp,e) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,c,tp,e) end
	-- 提示玩家选择表侧表示的卡（超量怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只除自身以外的表侧表示超量怪兽作为效果对象。
	Duel.SelectTarget(tp,s.xfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- ②效果的处理：将自身以及手卡·场上·墓地1只满足条件的怪兽重叠作为对象超量怪兽的超量素材。
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_ONFIELD) or not s.xyzfilter(c,tp,e) then return end
	-- 获取作为效果对象的超量怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 从手卡·场上·墓地选择1只除自身以外的满足条件的雷族·光属性·4星怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.xyzfilter),tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,1,c,tp,e)
	if g:GetCount()>0 then
		local mg=c+g
		-- 将自身和选中的怪兽重叠作为目标超量怪兽的超量素材。
		Duel.Overlay(tc,mg)
	end
end
