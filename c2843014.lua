--素早いマンボウ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己卡组把1只鱼族怪兽送去墓地。那之后，可以从自己卡组把1只「迅捷翻车鱼」特殊召唤。
function c2843014.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，从自己卡组把1只鱼族怪兽送去墓地。那之后，可以从自己卡组把1只「迅捷翻车鱼」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2843014,0))  --"送墓"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c2843014.condition)
	e1:SetTarget(c2843014.target)
	e1:SetOperation(c2843014.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查这张卡是否因战斗破坏被送进了墓地。
function c2843014.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 目标处理函数：必发效果始终返回可发动，并设置从自己卡组把1张卡送去墓地的操作信息。
function c2843014.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计从自己卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：检查卡片是否为可以送去墓地的鱼族怪兽。
function c2843014.filter1(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToGrave()
end
-- 过滤条件：检查卡片是否为可以特殊召唤的「迅捷翻车鱼」。
function c2843014.filter2(c,e,tp)
	return c:IsCode(2843014) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：从卡组选1只鱼族怪兽送墓，若有空位且卡组有「迅捷翻车鱼」，询问并执行特殊召唤。
function c2843014.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发送提示信息，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1只满足条件的鱼族怪兽。
	local g=Duel.SelectMatchingCard(tp,c2843014.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将所选鱼族怪兽以效果送去墓地，并判断是否成功送入墓地。
	if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		if ft<=0 then return end
		-- 从自己卡组检索第一张可特殊召唤的「迅捷翻车鱼」。
		local tc=Duel.GetFirstMatchingCard(c2843014.filter2,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可特殊召唤的「迅捷翻车鱼」，询问玩家是否将其特殊召唤。
		if tc and Duel.SelectYesNo(tp,aux.Stringid(2843014,1)) then  --"是否要特殊召唤「迅捷翻车鱼」？"
			-- 中断当前效果处理，使之后的特殊召唤与之前的送墓视为不同时处理。
			Duel.BreakEffect()
			-- 将该「迅捷翻车鱼」以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
