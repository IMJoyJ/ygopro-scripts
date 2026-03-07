--暗黒界の鬼神 ケルト
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让自己可以从卡组把1只恶魔族怪兽在自己或者对方场上特殊召唤。
function c34968834.initial_effect(c)
	-- 效果原文：①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让自己可以从卡组把1只恶魔族怪兽在自己或者对方场上特殊召唤。
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
-- 规则层面：判断此卡是否由效果从手卡丢入墓地，且为对方的效果导致丢弃
function c34968834.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 规则层面：设置效果处理时的操作信息，包括特殊召唤自身，若为对方丢弃则额外包含从卡组丢弃的分类
function c34968834.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置当前效果处理中将要特殊召唤的卡为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
-- 规则层面：定义过滤函数，用于筛选卡组中是否含有可特殊召唤的恶魔族怪兽
function c34968834.filter(c,e,tp)
	return c:IsRace(RACE_FIEND)
		-- 规则层面：判断自己场上是否有空位可特殊召唤该恶魔族怪兽
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 规则层面：判断对方场上是否有空位可特殊召唤该恶魔族怪兽
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 规则层面：主处理函数，先特殊召唤自身，再判断是否需要从卡组特殊召唤恶魔族怪兽
function c34968834.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 规则层面：尝试将自身特殊召唤到自己场上，若失败则返回
	if Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 规则层面：判断是否为对方丢弃且自己为原控制者，并且卡组中存在可特殊召唤的恶魔族怪兽
	if rp==1-tp and tp==e:GetLabel() and Duel.IsExistingMatchingCard(c34968834.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 规则层面：询问玩家是否要从卡组特殊召唤恶魔族怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(34968834,1)) then  --"是否要从自己卡组特殊召唤？"
		-- 规则层面：中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 规则层面：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 规则层面：从卡组中选择一张满足条件的恶魔族怪兽
		local g=Duel.SelectMatchingCard(tp,c34968834.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 规则层面：判断自己场上是否有空位可特殊召唤该怪兽
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 规则层面：判断对方场上是否有空位可特殊召唤该怪兽
			local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local op=0
			if b1 and b2 then
				-- 规则层面：让玩家在自己场上或对方场上特殊召唤中选择其一
				op=Duel.SelectOption(tp,aux.Stringid(34968834,2),aux.Stringid(34968834,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif b1 then
				-- 规则层面：让玩家选择在自己场上特殊召唤
				op=Duel.SelectOption(tp,aux.Stringid(34968834,2))  --"在自己场上特殊召唤"
			elseif b2 then
				-- 规则层面：让玩家选择在对方场上特殊召唤
				op=Duel.SelectOption(tp,aux.Stringid(34968834,3))+1  --"在对方场上特殊召唤"
			else return end
			if op==0 then
				-- 规则层面：将选中的怪兽特殊召唤到自己场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 规则层面：将选中的怪兽特殊召唤到对方场上
				Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
