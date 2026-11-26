--古の秘儀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·卡组·墓地把1只通常怪兽守备表示特殊召唤（从卡组特殊召唤的场合必须是4星以下）。自己场上有通常怪兽卡存在的场合，可以作为代替从以下效果选1个适用。
-- ●对方场上的怪兽全部破坏。
-- ●对方场上的魔法·陷阱卡全部破坏。
-- ●自己抽2张。
-- ●从自己或对方的墓地把1只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册1回合1次、可从手卡·卡组·墓地特召通常怪兽或在己方场上有通常怪兽卡时四选一适用的魔法卡发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·卡组·墓地把1只通常怪兽守备表示特殊召唤（从卡组特殊召唤的场合必须是4星以下）。自己场上有通常怪兽卡存在的场合，可以作为代替从以下效果选1个适用。●对方场上的怪兽全部破坏。●对方场上的魔法·陷阱卡全部破坏。●自己抽2张。●从自己或对方的墓地把1只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤己方手卡·卡组·墓地中可表侧守备表示特殊召唤的通常怪兽（若在卡组则限4星以下）
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL)
		and (not c:IsLocation(LOCATION_DECK) or c:IsLevelBelow(4))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤可以从墓地特殊召唤到己方场上的怪兽
function s.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤场上表侧表示且兼具通常与怪兽类型的通常怪兽卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 过滤属于魔法或陷阱卡类型的卡片
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动前确认基础特召选项b1或替代四选一选项b2中至少有一项满足发动条件，并登记特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断基础效果b1的第一项条件：己方怪兽区是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并判断己方卡组·手卡·墓地是否存在可守备表示特召的符合条件通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 判断替代效果b2的前提：己方场上是否存在表侧表示的通常怪兽卡
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 以及对方怪兽区是否存在怪兽（对应全破对方怪兽选项）
		and (Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 或对方场上是否存在除正在发动的此卡外的魔法·陷阱卡（对应全破对方魔陷选项）
			or Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,c)
			-- 或己方可以效果抽2张卡（对应抽2张选项）
			or Duel.IsPlayerCanDraw(tp,2)
			-- 或己方怪兽区有空位
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 且双方墓地中存在至少1只可特殊召唤到己方场上的怪兽（对应墓地苏生选项）
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp))
	if chk==0 then return b1 or b2 end
	-- 登记可能涉及从己方卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：重新校验基础效果与四个替代效果的合法性，决定执行通常怪兽守备特召或从可适用的替代效果中四选一执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查己方怪兽区是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再次检查己方卡组·手卡·墓地是否存在符合条件的通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 效果处理时检查己方场上当前是否存在表侧通常怪兽卡
	local res=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 判断替代选项1（破坏对方场上全部怪兽）当前是否可适用
	local b2=res and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 判断替代选项2（破坏对方场上全部魔陷）当前是否可适用
	local b3=res and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
	-- 判断替代选项3（己方抽2张）当前是否可适用
	local b4=res and Duel.IsPlayerCanDraw(tp,2)
	-- 结合己方怪兽区空位准备判断替代选项4
	local b5=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 受「王家长眠之谷」判定过滤后，检查双方墓地是否存在可特殊召唤的怪兽，确定替代选项4是否可适用
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	-- 若基础效果可行，且无可用替代效果或玩家选择不适用替代效果，则执行基础的通常怪兽特殊召唤
	if b1 and (not (b2 or b3 or b4 or b5) or not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then  --"是否适用其他效果？"
		-- 向己方发送选择要特殊召唤的通常怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 受「王家长眠之谷」判定过滤后，从己方卡组·手卡·墓地选择1只符合条件的通常怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的通常怪兽以表侧守备表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif b2 or b3 or b4 or b5 then
		-- 从当前满足条件的替代效果选项中让己方玩家选择1个适用
		local op=aux.SelectFromOptions(tp,
			{b2,aux.Stringid(id,2),1},  --"破坏怪兽"
			{b3,aux.Stringid(id,3),2},  --"破坏魔法·陷阱卡"
			{b4,aux.Stringid(id,4),3},  --"抽卡"
			{b5,aux.Stringid(id,5),4})  --"特殊召唤"
		if op==1 then
			-- 获取对方怪兽区的所有怪兽
			local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			-- 将对方场上的所有怪兽以效果破坏
			Duel.Destroy(sg,REASON_EFFECT)
		elseif op==2 then
			-- 获取对方场上的所有魔法·陷阱卡（排除与当前效果关联的自身）
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
			-- 将对方场上的所有魔法·陷阱卡以效果破坏
			Duel.Destroy(sg,REASON_EFFECT)
		elseif op==3 then
			-- 己方以效果从卡组抽2张卡
			Duel.Draw(tp,2,REASON_EFFECT)
		elseif op==4 then
			-- 向己方发送从墓地选择要特殊召唤的怪兽的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 受「王家长眠之谷」判定过滤后，从双方墓地选择1只可特殊召唤的怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将从墓地选中的怪兽以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
