--古の秘儀
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·卡组·墓地把1只4星以下的通常怪兽守备表示特殊召唤。自己场上有原本卡是通常怪兽的表侧表示怪兽存在的场合，可以作为代替从以下效果选择1个适用。●对方场上的怪兽全部破坏。●对方场上的魔法·陷阱卡全部破坏。●自己抽2张。●从自己或者对方的墓地把1只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌·墓地通常怪兽或卡组4星以下通常怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL)
		and (not c:IsLocation(LOCATION_DECK) or c:IsLevelBelow(4))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤可以特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤场上原本类型为通常怪兽的表侧表示怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&(TYPE_NORMAL+TYPE_MONSTER)==(TYPE_NORMAL+TYPE_MONSTER)
end
-- 过滤魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动目标与分支合法性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以从手牌·卡组·墓地特招通常怪兽
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查场上是否存在原本为通常怪兽的怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方怪兽区是否有怪兽可破坏
		and (Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查对方场上是否有魔陷可破坏
			or Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,c)
			-- 检查自己是否可以抽2张卡
			or Duel.IsPlayerCanDraw(tp,2)
			-- 检查自己怪兽区是否有空位
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查双方墓地是否存在可特殊召唤的怪兽
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp))
	if chk==0 then return b1 or b2 end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：根据选择执行特招通常怪兽或强化效果分支
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特招通常怪兽条件
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查场上是否存在原本为通常怪兽的怪兽
	local res=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 检查对方场上怪兽全部破坏分支是否满足
	local b2=res and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上魔陷全部破坏分支是否满足
	local b3=res and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
	-- 检查抽2张卡分支是否满足
	local b4=res and Duel.IsPlayerCanDraw(tp,2)
	-- 检查苏生墓地怪兽分支是否有空格
	local b5=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否有可特招怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	-- 选择是否适用通常怪兽特招效果
	if b1 and (not (b2 or b3 or b4 or b5) or not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		-- 提示选择要特殊召唤的通常怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌·卡组·墓地选择1只4星以下通常怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将通常怪兽守备表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif b2 or b3 or b4 or b5 then
		-- 玩家选择适用的强化效果分支
		local op=aux.SelectFromOptions(tp,
			{b2,aux.Stringid(id,2),1},
			{b3,aux.Stringid(id,3),2},
			{b4,aux.Stringid(id,4),3},
			{b5,aux.Stringid(id,5),4})
		if op==1 then
			-- 获取对方场上的所有怪兽
			local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			-- 破坏对方场上所有的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		elseif op==2 then
			-- 获取对方场上的所有魔法·陷阱卡
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
			-- 破坏对方场上所有的魔法·陷阱卡
			Duel.Destroy(sg,REASON_EFFECT)
		elseif op==3 then
			-- 自己从卡组抽2张卡
			Duel.Draw(tp,2,REASON_EFFECT)
		elseif op==4 then
			-- 提示选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从双方墓地选择1只怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽在自己场上特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
