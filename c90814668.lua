--タイラント・プランテーション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只效果怪兽解放才能发动。从自己墓地选原本的种族·属性和那只怪兽相同的1只效果怪兽以外的怪兽特殊召唤。
function c90814668.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只效果怪兽解放才能发动。从自己墓地选原本的种族·属性和那只怪兽相同的1只效果怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90814668+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c90814668.cost)
	e1:SetTarget(c90814668.target)
	e1:SetOperation(c90814668.activate)
	c:RegisterEffect(e1)
end
-- 设置标记值以在target函数中确认是否通过cost阶段进行发动检测
function c90814668.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤自身场上可解放的效果怪兽，且该怪兽解放后有可用怪兽区域，且墓地存在与其原本种族、属性相同的非效果怪兽
function c90814668.cfilter(c,e,tp)
	-- 检查卡片是否为效果怪兽，且该怪兽离开场上后是否能空出可用的怪兽区域
	return c:IsType(TYPE_EFFECT) and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己墓地是否存在至少1张与该怪兽原本种族和属性相同、且不等于该怪兽本身的非效果怪兽
		and Duel.IsExistingMatchingCard(c90814668.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetOriginalRace(),c:GetOriginalAttribute())
end
-- 过滤墓地中原本种族和属性与解放怪兽相同、且可以特殊召唤的非效果怪兽
function c90814668.spfilter(c,e,tp,race,att)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetOriginalRace()==race and c:GetOriginalAttribute()==att
end
-- 效果发动时的处理（检查是否能发动、选择并解放1只效果怪兽作为代价、记录其原本种族和属性、设置特殊召唤的操作信息）
function c90814668.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足解放条件的效果怪兽
		return Duel.CheckReleaseGroup(tp,c90814668.cfilter,1,nil,e,tp)
	end
	-- 给玩家发送提示信息：“请选择要解放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足解放条件的效果怪兽
	local g=Duel.SelectReleaseGroup(tp,c90814668.cfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetOriginalRace(),g:GetFirst():GetOriginalAttribute())
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(g,REASON_COST)
	-- 设置特殊召唤的操作信息（从墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理时的操作（检查怪兽区域、获取解放怪兽的种族和属性、从墓地选择并特殊召唤对应的非效果怪兽）
function c90814668.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local race,att=e:GetLabel()
	-- 给玩家发送提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张受王家之谷影响检测的、原本种族和属性与解放怪兽相同的非效果怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c90814668.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,race,att)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
