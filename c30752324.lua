--古の秘儀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·卡组·墓地把1只通常怪兽守备表示特殊召唤（从卡组特殊召唤的场合必须是4星以下）。自己场上有通常怪兽卡存在的场合，可以作为代替从以下效果选1个适用。
-- ●对方场上的怪兽全部破坏。
-- ●对方场上的魔法·陷阱卡全部破坏。
-- ●自己抽2张。
-- ●从自己或对方的墓地把1只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔法卡发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·卡组·墓地把1只通常怪兽守备表示特殊召唤（从卡组特殊召唤的场合必须是4星以下）。自己场上有通常怪兽卡存在的场合，可以作为代替从以下效果选1个适用。●对方场上的怪兽全部破坏。●对方场上的魔法·陷阱卡全部破坏。●自己抽2张。●从自己或对方的墓地把1只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡·卡组·墓地可以守备表示特殊召唤的通常怪兽（从卡组特殊召唤的必须是4星以下）
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL)
		and (not c:IsLocation(LOCATION_DECK) or c:IsLevelBelow(4))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤墓地可以特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤场上表侧表示的通常怪兽卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 过滤魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动条件判断及操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己怪兽区是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在满足条件的通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查自己场上是否存在表侧表示的通常怪兽卡
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在怪兽
		and (Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查对方场上是否存在魔法·陷阱卡
			or Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,c)
			-- 检查自己是否可以抽2张卡
			or Duel.IsPlayerCanDraw(tp,2)
			-- 检查怪兽区是否有空位
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查自己或对方墓地是否存在可以特殊召唤的怪兽
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp))
	if chk==0 then return b1 or b2 end
	-- 设置操作信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：根据场上情况特殊召唤通常怪兽或选择适用代替效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在满足条件的通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查自己场上是否存在表侧表示的通常怪兽卡
	local res=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 判断分支条件：对方场上怪兽全部破坏
	local b2=res and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 判断分支条件：对方场上魔法·陷阱卡全部破坏
	local b3=res and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
	-- 判断分支条件：自己抽2张卡
	local b4=res and Duel.IsPlayerCanDraw(tp,2)
	-- 检查自己怪兽区是否有空位
	local b5=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在可以不受王家长眠之谷影响特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	-- 判断是否执行原本的特殊召唤效果还是选择适用代替效果
	if b1 and (not (b2 or b3 or b4 or b5) or not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then  --"是否适用其他效果？"
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地选择1只满足条件的通常怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧守备表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif b2 or b3 or b4 or b5 then
		-- 让玩家从满足条件的代替效果中选择1个适用
		local op=aux.SelectFromOptions(tp,
			{b2,aux.Stringid(id,2),1},  --"破坏怪兽"
			{b3,aux.Stringid(id,3),2},  --"破坏魔法·陷阱卡"
			{b4,aux.Stringid(id,4),3},  --"抽卡"
			{b5,aux.Stringid(id,5),4})  --"特殊召唤"
		if op==1 then
			-- 获取对方场上的全部怪兽
			local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			-- 将对方场上的怪兽全部破坏
			Duel.Destroy(sg,REASON_EFFECT)
		elseif op==2 then
			-- 获取对方场上的全部魔法·陷阱卡
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
			-- 将对方场上的魔法·陷阱卡全部破坏
			Duel.Destroy(sg,REASON_EFFECT)
		elseif op==3 then
			-- 自己抽2张卡
			Duel.Draw(tp,2,REASON_EFFECT)
		elseif op==4 then
			-- 提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从双方墓地选择1只可以特殊召唤的怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽在自己场上特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
