--ギミック・パペット－ナイトメア
-- 效果：
-- 这张卡可以把自己场上表侧表示存在的1只超量怪兽解放从手卡特殊召唤。这个方法的「机关傀儡-梦魇」的特殊召唤1回合只能有1次。这个方法特殊召唤成功时，可以从自己的手卡·墓地选1只「机关傀儡-梦魇」特殊召唤。此外，这张卡特殊召唤成功的回合，自己不能把名字带有「机关傀儡」的怪兽以外的怪兽特殊召唤。
function c55204071.initial_effect(c)
	-- 这张卡可以把自己场上表侧表示存在的1只超量怪兽解放从手卡特殊召唤。这个方法的「机关傀儡-梦魇」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55204071+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c55204071.spcon)
	e1:SetTarget(c55204071.sptg)
	e1:SetOperation(c55204071.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，可以从自己的手卡·墓地选1只「机关傀儡-梦魇」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55204071,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c55204071.spcon2)
	e2:SetTarget(c55204071.sptg2)
	e2:SetOperation(c55204071.spop2)
	c:RegisterEffect(e2)
	-- 此外，这张卡特殊召唤成功的回合，自己不能把名字带有「机关傀儡」的怪兽以外的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c55204071.spop3)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的超量怪兽，且该怪兽解放后能空出可用的怪兽区域
function c55204071.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查该怪兽解放后，场上是否有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件：检查场上是否存在可解放的满足过滤条件的怪兽
function c55204071.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1只满足过滤条件、可因特殊召唤而解放的怪兽
	return Duel.CheckReleaseGroupEx(tp,c55204071.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择：玩家选择1只满足条件的怪兽作为解放对象，并将其记录在效果标签中
function c55204071.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上可因特殊召唤而解放的怪兽组，并过滤出满足条件的表侧表示超量怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c55204071.cfilter,nil,tp)
	-- 给玩家发送提示信息：请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：解放选定的怪兽
function c55204071.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选定的怪兽组
	Duel.Release(g,REASON_SPSUMMON)
end
-- 效果2发动的条件：此卡是通过自身特殊召唤规则特殊召唤成功的
function c55204071.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：卡名为「机关傀儡-梦魇」且可以被特殊召唤的怪兽
function c55204071.spfilter(c,e,tp)
	return c:IsCode(55204071) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的靶向/发动检查：检查怪兽区域是否有空位，且手卡或墓地是否存在至少1只「机关傀儡-梦魇」
function c55204071.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡或墓地中是否存在至少1只满足特殊召唤条件的「机关傀儡-梦魇」
		and Duel.IsExistingMatchingCard(c55204071.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果2的效果处理：从手卡或墓地选择1只「机关傀儡-梦魇」特殊召唤
function c55204071.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有空余的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的「机关傀儡-梦魇」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55204071.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果3的效果处理：注册一个全局效果，限制玩家在本回合不能特殊召唤「机关傀儡」以外的怪兽
function c55204071.spop3(e,tp,eg,ep,ev,re,r,rp,c)
	-- 此外，这张卡特殊召唤成功的回合，自己不能把名字带有「机关傀儡」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c55204071.splimit)
	-- 将不能特殊召唤特定怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤条件：不能特殊召唤非「机关傀儡」的怪兽
function c55204071.splimit(e,c)
	return not c:IsSetCard(0x1083)
end
