--クリボーを呼ぶ笛
-- 效果：
-- 把自己卡组1只「栗子球」或「羽翼栗子球」，加入手卡或者在自己场上特殊召唤。
function c20065322.initial_effect(c)
	-- 将卡号40640057（栗子球）登记为本卡记载的卡名，以便在规则上识别与「栗子球」相关的信息。
	aux.AddCodeList(c,40640057)
	-- 把自己卡组1只「栗子球」或「羽翼栗子球」，加入手卡或者在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20065322.target)
	e1:SetOperation(c20065322.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：卡必须是「栗子球」或「羽翼栗子球」，且满足能被加入手卡，或者在己方有可用怪兽区并能被特殊召唤时允许特殊召唤。
function c20065322.filter(c,ft,e,tp)
	return c:IsCode(40640057,57116033) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果发动时的目标判定：检查己方卡组是否存在至少1只符合条件的「栗子球」或「羽翼栗子球」，且至少有一种处理方式（加入手卡或特殊召唤）可行。
function c20065322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方场上主要怪兽区的可用空格数量，用于判断是否满足特殊召唤条件。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查卡组中是否存在1张满足自定义筛选条件的卡，筛选时传入可用怪兽区数量、效果e和操作玩家。
		return Duel.IsExistingMatchingCard(c20065322.filter,tp,LOCATION_DECK,0,1,nil,ft,e,tp)
	end
end
-- 效果处理：读取可用怪兽区数量，提示玩家选择，从卡组选择1张符合条件的卡；若选择成功则根据该卡是否能加入手卡/特殊召唤来决定处理方式，并执行对应的操作。
function c20065322.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上主要怪兽区的可用空格数量，用于后续判断特殊召唤是否可行。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 给出选择提示，让玩家从符合条件的卡片中选取要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中精确选择1张符合筛选条件的「栗子球」或「羽翼栗子球」，并将选择结果作为对象。
	local g=Duel.SelectMatchingCard(tp,c20065322.filter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp)
	if g:GetCount()>0 then
		local th=g:GetFirst():IsAbleToHand()
		local sp=ft>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		-- 若选中的卡既能加入手卡又能特殊召唤，则弹出选项让玩家选择其中一种处理方式；选项文本由对应描述常量指定。
		if th and sp then op=Duel.SelectOption(tp,1190,1152)
		elseif th then op=0
		else op=1 end
		if op==0 then
			-- 将选中的卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示刚刚加入手卡的卡牌，以示确认。
			Duel.ConfirmCards(1-tp,g)
		else
			-- 将选中的卡以正面表示特殊召唤到己方场上，不检查召唤条件与苏生限制。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
