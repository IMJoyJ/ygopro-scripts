--暗黒界の術師 スノウ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。从卡组把1张「暗黑界」卡加入手卡。被对方的效果丢弃的场合，发动时可以以对方墓地1只怪兽为对象。那个场合，再让以下效果适用。
-- ●作为对象的怪兽在自己场上守备表示特殊召唤。
function c60228941.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。从卡组把1张「暗黑界」卡加入手卡。被对方的效果丢弃的场合，发动时可以以对方墓地1只怪兽为对象。那个场合，再让以下效果适用。●作为对象的怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60228941,0))  --"检索"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c60228941.condition)
	e1:SetTarget(c60228941.target)
	e1:SetOperation(c60228941.operation)
	c:RegisterEffect(e1)
end
-- 判定此卡是否被效果从手卡丢弃去墓地，并记录其原本的控制者
function c60228941.condition(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 效果发动时的处理：确定检索操作信息，若被对方效果丢弃且满足条件，可选择是否以对方墓地1只怪兽为对象并设置特召操作信息
function c60228941.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c60228941.filter2(chkc,e,tp) end
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 判定是否为对方的效果丢弃，且自己场上有空余的怪兽区域
	if rp==1-tp and tp==e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定对方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c60228941.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp)
		-- 询问玩家是否选择发动追加效果（以对方墓地1只怪兽为对象特殊召唤）
		and Duel.SelectYesNo(tp,aux.Stringid(60228941,1)) then  --"是否要特殊召唤对方墓地的怪兽？"
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择对方墓地1只满足特殊召唤条件的怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c60228941.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 设置操作信息：将选中的对象怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
end
-- 过滤条件：卡名带有「暗黑界」且能加入手卡的卡
function c60228941.filter1(c)
	return c:IsSetCard(0x6) and c:IsAbleToHand()
end
-- 过滤条件：可以以表侧守备表示特殊召唤的怪兽
function c60228941.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理：从卡组将1张「暗黑界」卡加入手卡。若满足追加效果条件且已选择对象，则在加入手卡后将该对象怪兽在自己场上守备表示特殊召唤
function c60228941.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「暗黑界」卡
	local g=Duel.SelectMatchingCard(tp,c60228941.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「暗黑界」卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取发动时选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 中断当前效果，使后续的特殊召唤处理与加入手卡不视为同时处理
			Duel.BreakEffect()
			-- 将对象怪兽在自己场上表侧守备表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
