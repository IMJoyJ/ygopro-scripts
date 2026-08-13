--C・パンテール
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·黑暗豹」。
function c43751755.initial_effect(c)
	-- 登记这张卡的效果文本中提及的「新空间侠·黑暗豹」（43237273）的卡号。
	aux.AddCodeList(c,43237273)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·黑暗豹」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43751755,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43751755.spcon)
	e1:SetCost(c43751755.spcost)
	e1:SetTarget(c43751755.sptg)
	e1:SetOperation(c43751755.spop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：场上有「新宇宙」存在时才能发动。
function c43751755.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否存在场地魔法「新宇宙」（卡号42015635）。
	return Duel.IsEnvironment(42015635)
end
-- 定义发动代价：先检查这张卡是否可被解放，然后将自身解放作为代价。
function c43751755.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将效果持有者（这张卡自身）解放，作为发动效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤对象的筛选条件：必须是「新空间侠·黑暗豹」（43237273），且能被当前效果特殊召唤。
function c43751755.spfilter(c,e,tp)
	return c:IsCode(43237273) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的合法性检查：确认己方怪兽区域可用，且手卡·卡组存在符合条件的「新空间侠·黑暗豹」。
function c43751755.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在可用的怪兽区域（因代价会解放自身，所以允许当前区域已被占满）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认手卡或卡组中存在至少1只满足特殊召唤条件的「新空间侠·黑暗豹」。
		and Duel.IsExistingMatchingCard(c43751755.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果的特殊召唤操作信息：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理：若场上无空位或「新宇宙」已不在场则终止；否则从手卡·卡组选择并特殊召唤1只「新空间侠·黑暗豹」。
function c43751755.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若己方场上没有可用怪兽区域，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认「新宇宙」在场，若不在则不进行特殊召唤。
	if not Duel.IsEnvironment(42015635) then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只符合条件的「新空间侠·黑暗豹」。
	local g=Duel.SelectMatchingCard(tp,c43751755.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「新空间侠·黑暗豹」以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
