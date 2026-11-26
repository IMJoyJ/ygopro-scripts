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
-- 效果①的Condition函数：记录这张卡离开手卡前的控制者到Label，并检查是否因效果从手卡被丢弃送去墓地（r同时包含REASON_EFFECT与REASON_DISCARD）
function c34968834.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 效果①的Target函数：始终通过发动检测，设置特召自身的操作信息，并在由对方效果从己方手卡丢弃时追加卡组特召类别
function c34968834.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_DECK_SPSUMMON)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
-- 过滤函数：筛选卡组中可以在自己场上或对方场上特殊召唤的恶魔族(RACE_FIEND)怪兽
function c34968834.filter(c,e,tp)
	return c:IsRace(RACE_FIEND)
		-- 检查己方主要怪兽区是否有空位且该恶魔族怪兽可以被特殊召唤到己方场上
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 或者检查对方主要怪兽区是否有空位且该恶魔族怪兽可以被特殊召唤到对方场上
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 效果①的Operation函数：先将这张卡特殊召唤，若被对方效果从己方手卡丢弃，可询问玩家从卡组选1只恶魔族怪兽在自己或对方场上特殊召唤
function c34968834.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方场上，若特殊召唤失败则中止后续处理
	if Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查是否被对方效果丢弃且己方卡组中存在可在双方场上之一特殊召唤的恶魔族怪兽
	if rp==1-tp and tp==e:GetLabel() and Duel.IsExistingMatchingCard(c34968834.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问己方玩家是否要从己方卡组特殊召唤1只恶魔族怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(34968834,1)) then  --"是否要从自己卡组特殊召唤？"
		-- 中断当前处理步骤，使后续卡组特召与这张卡自身的特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 向己方玩家发送选择要特殊召唤的恶魔族怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组中选择1只可特殊召唤的恶魔族怪兽
		local g=Duel.SelectMatchingCard(tp,c34968834.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 检查所选恶魔族怪兽是否能特殊召唤到己方怪兽区
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查所选恶魔族怪兽是否能特殊召唤到对方怪兽区
			local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local op=0
			if b1 and b2 then
				-- 当双方场上均可特殊召唤时，让玩家选择在自己场上还是对方场上特殊召唤
				op=Duel.SelectOption(tp,aux.Stringid(34968834,2),aux.Stringid(34968834,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif b1 then
				-- 当仅自己场上可特殊召唤时，向玩家提示并确认在自己场上特殊召唤
				op=Duel.SelectOption(tp,aux.Stringid(34968834,2))  --"在自己场上特殊召唤"
			elseif b2 then
				-- 当仅对方场上可特殊召唤时，向玩家提示并确认在对方场上特殊召唤（选项索引偏移为1）
				op=Duel.SelectOption(tp,aux.Stringid(34968834,3))+1  --"在对方场上特殊召唤"
			else return end
			if op==0 then
				-- 将选中的恶魔族怪兽以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将选中的恶魔族怪兽以表侧表示特殊召唤到对方场上
				Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
