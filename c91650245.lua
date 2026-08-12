--森羅の恵み
-- 效果：
-- 选1张手卡回到持有者卡组最上面或者最下面，从自己的手卡·墓地选1只名字带有「森罗」的怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不受这张卡以外的卡的效果影响，结束阶段时回到持有者卡组最上面或者最下面。
function c91650245.initial_effect(c)
	-- 选1张手卡回到持有者卡组最上面或者最下面，从自己的手卡·墓地选1只名字带有「森罗」的怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不受这张卡以外的卡的效果影响，结束阶段时回到持有者卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c91650245.target)
	e1:SetOperation(c91650245.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选手卡中可以送回卡组，且手卡·墓地存在可特殊召唤的「森罗」怪兽的卡片
function c91650245.filter(c,e,tp)
	-- 检查该卡是否能回到卡组，且手卡·墓地存在除该卡以外的、可特殊召唤的「森罗」怪兽
	return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(c91650245.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤函数：用于筛选手卡·墓地中可以特殊召唤的「森罗」怪兽
function c91650245.spfilter(c,e,tp)
	return c:IsSetCard(0x90) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标过滤与合法性检查
function c91650245.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的卡（能回卡组且有可特召的森罗怪兽）
		and Duel.IsExistingMatchingCard(c91650245.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理的执行函数
function c91650245.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则无法特殊召唤，直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c91650245.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家选择将卡片返回卡组最上面还是最下面
		local opt=Duel.SelectOption(tp,aux.Stringid(91650245,0),aux.Stringid(91650245,1))  --"返回卡组最上面/返回卡组最下面"
		-- 将选中的手卡按玩家选择的位置（最上面或最下面）送回卡组
		Duel.SendtoDeck(g,nil,opt,REASON_EFFECT)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡或墓地选择1只名字带有「森罗」的怪兽（受王家长眠之谷影响，且排除刚才送回卡组的那张卡）
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91650245.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,tc,e,tp)
		local sc=sg:GetFirst()
		if sc then
			-- 将选中的「森罗」怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			-- 结束阶段时回到持有者卡组最上面或者最下面。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetOperation(c91650245.tdop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽在这个回合不受这张卡以外的卡的效果影响
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(c91650245.efilter)
			sc:RegisterEffect(e2)
		end
	end
end
-- 结束阶段时将特殊召唤的怪兽送回卡组的处理函数
function c91650245.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsExtraDeckMonster()
		-- 若该怪兽是额外怪兽，或者玩家选择将其返回卡组最上面
		or Duel.SelectOption(tp,aux.Stringid(91650245,0),aux.Stringid(91650245,1))==0 then  --"返回卡组最上面/返回卡组最下面"
		-- 将该怪兽送回持有者卡组最上面
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	else
		-- 将该怪兽送回持有者卡组最下面
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 免疫效果的过滤函数，判定是否为这张卡以外的卡的效果
function c91650245.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
