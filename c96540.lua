--ダウンビート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽解放才能发动。和解放的怪兽是原本的种族·属性相同而原本等级低1星的1只怪兽从卡组特殊召唤。
function c96540.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示怪兽解放才能发动。和解放的怪兽是原本的种族·属性相同而原本等级低1星的1只怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,96540+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c96540.cost)
	e1:SetTarget(c96540.target)
	e1:SetOperation(c96540.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
-- 用于在发动时标记并检测解放代价的cost函数
function c96540.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤满足解放条件且卡组有可特召对应怪兽的场上怪兽的过滤函数
function c96540.costfilter(c,e,tp)
	-- 检查怪兽是否表侧表示、原本等级大于0，且卡组中存在满足特召条件的怪兽
	return c:IsFaceup() and c:GetOriginalLevel()>0 and Duel.IsExistingMatchingCard(c96540.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
		-- 检查该怪兽解放后，场上是否有可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤卡组中与被解放怪兽原本种族和属性相同、原本等级低1星且可以特殊召唤的怪兽的过滤函数
function c96540.spfilter(c,tc,e,tp)
	return c:GetOriginalLevel()==tc:GetOriginalLevel()-1
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理（检查可行性、选择并解放怪兽、设置效果处理对象及操作信息）
function c96540.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否满足发动条件（通过cost标记检测，并确认场上是否存在可解放的合法怪兽）
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.CheckReleaseGroup(tp,c96540.costfilter,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 让玩家选择1只满足条件的场上怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c96540.costfilter,1,1,nil,e,tp)
	-- 将选择的怪兽解放作为发动的代价
	Duel.Release(g,REASON_COST)
	-- 将解放的怪兽设置为效果处理的对象（用于后续获取其原本属性、种族和等级）
	Duel.SetTargetCard(g)
	-- 设置效果处理的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的函数（从卡组特殊召唤符合条件的怪兽）
function c96540.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无空位则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取作为发动代价被解放的怪兽（即之前设置的对象卡）
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与被解放怪兽原本种族·属性相同且原本等级低1星的怪兽
	local g=Duel.SelectMatchingCard(tp,c96540.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在自身场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
