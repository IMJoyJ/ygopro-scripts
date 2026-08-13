--素早いマンボウ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己卡组把1只鱼族怪兽送去墓地。那之后，可以从自己卡组把1只「迅捷翻车鱼」特殊召唤。
function c2843014.initial_effect(c)
	-- 对应效果原文：这张卡被战斗破坏送去墓地时，从自己卡组把1只鱼族怪兽送去墓地。那之后，可以从自己卡组把1只「迅捷翻车鱼」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2843014,0))  --"送墓"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c2843014.condition)
	e1:SetTarget(c2843014.target)
	e1:SetOperation(c2843014.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：这张卡被战斗破坏后必须位于墓地，且破坏原因为战斗破坏，才满足诱发条件。
function c2843014.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 发动时点处理：允许效果发动，并预宣告本效果包含把卡组卡送去墓地的信息。
function c2843014.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 预宣告操作信息：将进行一次从卡组把1张卡送去墓地的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓检索过滤器：选择卡组中1只鱼族怪兽且能够送去墓地的卡。
function c2843014.filter1(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToGrave()
end
-- 特殊召唤检索过滤器：选择卡组中卡名为「迅捷翻车鱼」且能够被特殊召唤的卡。
function c2843014.filter2(c,e,tp)
	return c:IsCode(2843014) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：先选1只鱼族怪兽送去墓地，若成功且己方主要怪兽区有空位，则选1只「迅捷翻车鱼」询问玩家是否特殊召唤。
function c2843014.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区的可用空格数，用于判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向操作者显示送墓选卡提示，并弹出对应的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选出1张满足鱼族且可送墓的卡。
	local g=Duel.SelectMatchingCard(tp,c2843014.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地，并确认是否成功送墓。
	if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		if ft<=0 then return end
		-- 从己方卡组检索第一张满足条件的「迅捷翻车鱼」。
		local tc=Duel.GetFirstMatchingCard(c2843014.filter2,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若存在可特殊召唤的「迅捷翻车鱼」且玩家选择同意，则继续处理特殊召唤。
		if tc and Duel.SelectYesNo(tp,aux.Stringid(2843014,1)) then  --"是否要特殊召唤「迅捷翻车鱼」？"
			-- 中断当前效果链，使特殊召唤处理与之前的送墓处理视为不同时进行，避免错时点问题。
			Duel.BreakEffect()
			-- 将检索到的「迅捷翻车鱼」以表侧攻击表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
