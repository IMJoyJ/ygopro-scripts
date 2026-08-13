--暗黒界の鬼神 ケルト
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让自己可以从卡组把1只恶魔族怪兽在自己或者对方场上特殊召唤。
function c34968834.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让自己可以从卡组把1只恶魔族怪兽在自己或者对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34968834,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c34968834.spcon)
	e1:SetTarget(c34968834.sptg)
	e1:SetOperation(c34968834.spop)
	c:RegisterEffect(e1)
end
-- 诱发条件判定：记录这张卡在被丢弃前的控制者；并检查它之前位于手牌，且丢弃原因满足“被效果从手卡丢弃”（含作为代价丢弃）。
function c34968834.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 发动时目标处理：不取对象；若可发动则登记将特殊召唤自身；并根据该丢弃是否由对方的效果导致（丢弃前控制者为当前玩家）来追加“从卡组特召”的分类。
function c34968834.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁的操作信息：效果将把这张卡自身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
-- 定义追加特召的怪兽筛选条件：恶魔族怪兽，且能够被特殊召唤到自己或对方的空余怪兽区域。
function c34968834.filter(c,e,tp)
	return c:IsRace(RACE_FIEND)
		-- 检查自己场上是否有可用怪兽区，并且该怪兽能被自己以表侧表示特殊召唤到自己场上。
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 检查对方场上是否有可用怪兽区，并且该怪兽能被自己以表侧表示特殊召唤到对方场上（表侧表示）。
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 效果结算：先将这张卡特殊召唤；若成功且满足“因对方效果丢弃”且卡组存在符合条件的恶魔族怪兽，则询问玩家是否继续从卡组特召；若同意，则选择一张符合条件的怪兽，并按选择或可行区域特召到自己或对方场上。
function c34968834.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 将这张卡自身特殊召唤到当前玩家场上；若特殊召唤未能成功（返回0），则不再处理后续追加效果。
	if Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 判断是否满足追加特召条件：该丢弃是由对方的效果引起的，且丢弃前这张卡的控制者是当前玩家，且卡组中存在符合条件的恶魔族怪兽。
	if rp==1-tp and tp==e:GetLabel() and Duel.IsExistingMatchingCard(c34968834.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 让当前玩家选择是否从卡组特殊召唤怪兽（是/否）。
		and Duel.SelectYesNo(tp,aux.Stringid(34968834,1)) then  --"是否要从自己卡组特殊召唤？"
		-- 中断当前效果处理，使后续追加的特殊召唤与之前的特殊召唤不同时处理（错开时点）。
		Duel.BreakEffect()
		-- 弹出“请选择要特殊召唤的卡”的提示信息，供选择卡组中的怪兽时显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从当前玩家的卡组中选择1张满足filter条件的恶魔族怪兽（处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,c34968834.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 判定该怪兽能否特殊召唤到自己场上：自己场上是否有空位，且该怪兽能否被自己特殊召唤。
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判定该怪兽能否特殊召唤到对方场上：对方场上是否有空位，且该怪兽能否被自己以表侧表示特殊召唤到对方场上。
			local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local op=0
			if b1 and b2 then
				-- 当两个场地均可时，让玩家二选一：在自己场上特殊召唤，还是在对方场上特殊召唤。
				op=Duel.SelectOption(tp,aux.Stringid(34968834,2),aux.Stringid(34968834,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif b1 then
				-- 当只有自己场上可特召时，让玩家选择“在自己场上特殊召唤”（唯一选项）。
				op=Duel.SelectOption(tp,aux.Stringid(34968834,2))  --"在自己场上特殊召唤"
			elseif b2 then
				-- 当只有对方场上可特召时，让玩家选择“在对方场上特殊召唤”（唯一选项；返回0后加1，映射到对方场分支）。
				op=Duel.SelectOption(tp,aux.Stringid(34968834,3))+1  --"在对方场上特殊召唤"
			else return end
			if op==0 then
				-- 将选择的怪兽表侧表示特殊召唤到当前玩家自己场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将选择的怪兽表侧表示特殊召唤到对方（1-tp）场上。
				Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
