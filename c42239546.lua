--C・モーグ
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·大地鼹鼠」。
function c42239546.initial_effect(c)
	-- 登记本卡记述的卡名「新空间侠·大地鼹鼠」（卡号80344569），使需要参照此卡名的检索/效果判定可用IsCode检查。
	aux.AddCodeList(c,80344569)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·大地鼹鼠」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42239546,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c42239546.spcon)
	e1:SetCost(c42239546.spcost)
	e1:SetTarget(c42239546.sptg)
	e1:SetOperation(c42239546.spop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：场上有「新宇宙」存在时才能发动。
function c42239546.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上生效的场地卡是否为「新宇宙」（卡号42015635），是则满足条件。
	return Duel.IsEnvironment(42015635)
end
-- 定义效果发动的代价：解放这张卡（作为祭品）。
function c42239546.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡以代价形式解放（送入墓地）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选符合条件的特殊召唤对象：卡号为80344569（「新空间侠·大地鼹鼠」），且当前玩家tp可以将其特殊召唤。
function c42239546.spfilter(c,e,tp)
	return c:IsCode(80344569) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标条件：自己场上存在可用的怪兽区域（解放后会腾出位置），且手卡·卡组中有符合条件的目标。
function c42239546.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否至少有一个可用的怪兽区（解放后空出位置也算可用，故只需可用数量＞-1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组中是否存在至少1张满足过滤条件的「新空间侠·大地鼹鼠」。
		and Duel.IsExistingMatchingCard(c42239546.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次操作信息为特殊召唤，对象来自手卡·卡组，数量为1，持有者为当前玩家，供连锁判定与效果响应使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理：若仍有空位且场上的「新宇宙」仍存在，则选择1张「新空间侠·大地鼹鼠」特殊召唤。
function c42239546.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用怪兽区域，则本次特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认场上的「新宇宙」仍在，若已不在则效果不处理。
	if not Duel.IsEnvironment(42015635) then return end
	-- 向玩家显示特殊召唤的选择提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组中选择1张符合条件的「新空间侠·大地鼹鼠」。
	local g=Duel.SelectMatchingCard(tp,c42239546.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡正面表示特殊召唤到自己场上，不检查召唤条件与苏生限制（已在筛选时确认）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
