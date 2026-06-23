--F.A.シェイクダウン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，选场上1张卡破坏。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「方程式运动员」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c38459905.initial_effect(c)
	-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，选场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38459905)
	e1:SetTarget(c38459905.target)
	e1:SetOperation(c38459905.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「方程式运动员」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,38459906)
	-- 效果发动时，检查是否为该卡送去墓地的回合，若是则不能发动
	e2:SetCondition(aux.exccon)
	-- 效果发动时，将此卡从游戏中除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38459905.sptg)
	e2:SetOperation(c38459905.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选自己场上满足条件的「方程式运动员」怪兽（表侧表示、拥有「方程式运动员」字段、可以改变表示形式）
function c38459905.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:IsCanChangePosition()
end
-- 处理效果①的发动条件和选择对象，选择自己场上1只满足条件的怪兽作为对象
function c38459905.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38459905.filter(chkc) end
	-- 检查是否满足效果①的发动条件，即自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c38459905.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c38459905.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果①的处理信息，表示形式变更效果
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置效果①的处理信息，破坏场上1张卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
-- 处理效果①的发动效果，先改变目标怪兽的表示形式，再破坏场上1张卡
function c38459905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上且与效果相关，然后改变其表示形式
	if tc and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		-- 获取场上所有卡的集合
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		if g:GetCount()==0 then return end
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 破坏选择的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选自己场上满足条件的卡（表侧表示、有可用怪兽区）
function c38459905.desfilter(c,tp)
	-- 判断目标卡是否为表侧表示且自己有可用怪兽区
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，用于筛选可以特殊召唤的「方程式运动员」怪兽
function c38459905.spfilter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果②的发动条件和选择对象，选择自己场上1张满足条件的卡作为对象
function c38459905.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c38459905.desfilter(chkc,tp) end
	-- 检查是否满足效果②的发动条件，即自己场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c38459905.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		-- 检查是否满足效果②的发动条件，即卡组中是否存在满足条件的「方程式运动员」怪兽
		and Duel.IsExistingMatchingCard(c38459905.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的卡作为对象
	local g=Duel.SelectTarget(tp,c38459905.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置效果②的处理信息，破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果②的处理信息，特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果②的发动效果，先破坏目标卡，再从卡组特殊召唤1只「方程式运动员」怪兽
function c38459905.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上且与效果相关，然后破坏该卡
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查自己场上是否有可用怪兽区
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的「方程式运动员」怪兽
		local g=Duel.SelectMatchingCard(tp,c38459905.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
