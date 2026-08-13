--白き乙女
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·卡组·墓地把1张「真正之光」在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡在墓地存在的状态，自己把「青眼白龙」特殊召唤的场合才能发动。这张卡特殊召唤。
-- ③：场上的这张卡成为攻击·效果的对象时才能发动。从自己墓地把1只「青眼白龙」或光属性·1星调整特殊召唤。
local s,id,o=GetID()
-- 初始化函数：登记卡名相关代码列表，创建并注册①表侧放置「真正之光」的起动效果、②墓地特殊召唤自己的诱发效果、③成为效果对象时的诱发即时效果，以及克隆得到的成为攻击对象版效果。
function s.initial_effect(c)
	-- 将「青眼白龙」和「真正之光」的卡号加入此卡的记述卡名列表，供涉及卡名记述的检索/判定使用。
	aux.AddCodeList(c,89631139,62089826)
	-- 为这张卡注册“已在墓地”的状态检测标记效果，用于在同一连锁中正确判断其是否在特殊召唤前已存在于墓地。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 对应①效果：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·卡组·墓地把1张「真正之光」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"表侧放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.pcost)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- 对应②效果：这张卡在墓地存在的状态，自己把「青眼白龙」特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 对应③效果：场上的这张卡成为攻击·效果的对象时才能发动。从自己墓地把1只「青眼白龙」或光属性·1星调整特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e4)
end
-- ①效果的代价函数：先检查这张卡能否作为代价送去墓地；满足后实际将其以代价原因送去墓地。
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将发动效果的那张卡（白色少女）以代价原因送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：选择「真正之光」，要求该卡不是禁止卡，且自己场上不存在同名卡（满足同名卡限制）。
function s.pfilter(c,tp)
	return c:IsCode(62089826)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的目标条件：确认魔陷区有空位，且自己的手牌·卡组·墓地中存在至少1张满足pfilter的「真正之光」。
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己的魔法与陷阱区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的手牌·卡组·墓地中是否存在至少1张符合条件的「真正之光」。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
end
-- ①效果处理：处理时若魔陷区无空位则终止；提示选择放置到场上的卡；从手牌·卡组·墓地选择1张「真正之光」，不受王家长眠之谷影响时表侧放置到自己的魔法与陷阱区域。
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认魔法与陷阱区域仍有空位，否则不进行后续处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 给当前玩家显示“请选择要放置到场上的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己的手牌·卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「真正之光」。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	-- 将选择的「真正之光」以表侧表示移动到自己的魔法与陷阱区域，并立即适用其效果。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 用于②效果的特殊召唤事件过滤：本次特殊召唤的怪兽是表侧表示的「青眼白龙」，召唤玩家是自己，且该特殊召唤不是由本效果自身引发的，避免循环触发。
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsCode(89631139)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：从效果LabelObject中取得墓地状态标记，并检查本次特殊召唤成功事件中是否存在满足cfilter的「青眼白龙」。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- ②效果的目标条件：确认主要怪兽区有空位，且这张卡自身可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己的主要怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理包含将这张卡自身特殊召唤，用于星尘龙等卡片的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联且不受王家长眠之谷影响，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前确认：这张卡与效果仍有关联（未中途离场等），且不受王家长眠之谷影响，否则不处理。
	if not c:IsRelateToEffect(e) or not aux.NecroValleyFilter()(c) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件：本次成为攻击对象/效果对象的事件中包含这张卡自身。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 特殊召唤对象过滤：目标为墓地的「青眼白龙」，或光属性·1星·调整怪兽，并且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return (c:IsCode(89631139) or c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标条件：确认主要怪兽区有空位，且墓地存在至少1只满足spfilter的怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己的主要怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只满足条件且可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理包含从墓地特殊召唤1只怪兽，用于时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：若主要怪兽区无空位则终止；提示选择特殊召唤的卡；从墓地选择1只满足条件且不受王家长眠之谷影响的怪兽，以表侧表示特殊召唤到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区域仍有空位，否则不进行后续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给当前玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter且不受王家长眠之谷影响的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
