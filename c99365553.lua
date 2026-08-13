--ライトパルサー・ドラゴン
-- 效果：
-- 这张卡可以把自己墓地的光属性和暗属性的怪兽各1只从游戏中除外，从手卡特殊召唤。此外，可以把手卡的光属性和暗属性的怪兽各1只送去墓地，并把这张卡从自己墓地特殊召唤。这张卡从场上送去墓地时，可以选择自己墓地1只龙族·暗属性·5星以上的怪兽特殊召唤。
function c99365553.initial_effect(c)
	-- 这张卡可以把自己墓地的光属性和暗属性的怪兽各1只从游戏中除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c99365553.spcon1)
	e1:SetTarget(c99365553.sptg1)
	e1:SetOperation(c99365553.spop1)
	c:RegisterEffect(e1)
	-- 此外，可以把手卡的光属性和暗属性的怪兽各1只送去墓地，并把这张卡从自己墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c99365553.spcon2)
	e2:SetTarget(c99365553.sptg2)
	e2:SetOperation(c99365553.spop2)
	c:RegisterEffect(e2)
	-- 这张卡从场上送去墓地时，可以选择自己墓地1只龙族·暗属性·5星以上的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99365553,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c99365553.spcon3)
	e3:SetTarget(c99365553.sptg3)
	e3:SetOperation(c99365553.spop3)
	c:RegisterEffect(e3)
end
-- 定义手卡特召的代价过滤条件：该卡必须能够作为代价从墓地除外，且属性为光属性或暗属性。
function c99365553.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 定义墓地特召的代价过滤条件：该卡必须能够作为代价从手牌送去墓地，且属性为光属性或暗属性。
function c99365553.spcostfilter2(c)
	return c:IsAbleToGraveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 手卡特召的召唤条件：当c为空时直接允许，否则需要场上有空余怪兽区，且墓地存在光属性与暗属性怪兽各1只。
function c99365553.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有空余的怪兽区域，没有空位则无法进行特殊召唤。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有能够作为代价除外且属性为光或暗的怪兽，用于后续选择。
	local g=Duel.GetMatchingGroup(c99365553.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 检查组中能否同时选出2张卡，分别满足光属性和暗属性（即光暗各1只）。
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 手卡特召的代价选择：从墓地选择光属性和暗属性的怪兽各1只作为除外代价，保存到效果对象中；选择成功则返回true。
function c99365553.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取墓地中可作为代价且光/暗属性的卡组，供玩家选择。
	local g=Duel.GetMatchingGroup(c99365553.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 发送选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选组中由玩家选择2张卡，要求一张光属性一张暗属性，作为除外代价。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 手卡特召的实际代价处理：将选中的光/暗怪兽各1只从墓地除外，然后清除临时保存的组。
function c99365553.spop1(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的卡以表侧表示从游戏中除外，除外原因记为该卡的特殊召唤代价。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 墓地特召的召唤条件：若此卡没有受到“王家长眠之谷”的限制、场上有空位，并且手牌中存在光属性与暗属性怪兽各1只，则满足条件。
function c99365553.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若此卡受到“王家长眠之谷”效果影响无法从墓地特殊召唤，或场上没有空位，则返回false。
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) or Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取手牌中所有能够作为代价送去墓地且属性为光或暗的怪兽，用于后续选择。
	local g=Duel.GetMatchingGroup(c99365553.spcostfilter2,tp,LOCATION_HAND,0,nil)
	-- 检查组中能否同时选出2张卡，分别满足光属性和暗属性（即手牌光暗各1只）。
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 墓地特召的代价选择：从手牌选择光属性和暗属性的怪兽各1只作为送墓代价，保存到效果对象中；选择成功则返回true。
function c99365553.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中可作为代价且光/暗属性的卡组，供玩家选择。
	local g=Duel.GetMatchingGroup(c99365553.spcostfilter2,tp,LOCATION_HAND,0,nil)
	-- 发送选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从候选组中由玩家选择2张卡，要求一张光属性一张暗属性，作为送墓代价。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 墓地特召的实际代价处理：将选中的光/暗怪兽各1只从手牌送去墓地，然后清除临时保存的组。
function c99365553.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的2张卡送去墓地，送去墓地原因记为该卡的特殊召唤代价。
	Duel.SendtoGrave(sg,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 第三个效果的发动条件：本卡被送去墓地前位于场上（即从场上送入墓地时才能发动）。
function c99365553.spcon3(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义特殊召唤对象过滤：目标必须是等级5以上、暗属性、龙族，且满足特殊召唤条件。
function c99365553.spfilter3(c,e,tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第三个效果发动时的目标检查和选择：若已指定对象则检查该对象是否合法；否则检查场上有空位且墓地存在符合条件的目标。
function c99365553.sptg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99365553.spfilter3(chkc,e,tp) end
	-- 检查场上是否有空余的怪兽区域，以确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的龙族·暗属性·5星以上怪兽可以作为特殊召唤对象。
		and Duel.IsExistingTarget(c99365553.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 发送选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的候选卡中由玩家选择1张符合条件的怪兽，并设置为效果对象。
	local g=Duel.SelectTarget(tp,c99365553.spfilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果为特殊召唤，目标为已选择的卡g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 第三个效果处理：将效果对象（选择的墓地怪兽）特殊召唤到自己场上。
function c99365553.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上，完成特殊召唤处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
