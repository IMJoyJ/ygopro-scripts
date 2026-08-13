--明と宵の逆転
-- 效果：
-- 可以从以下效果选择1个发动。「明与宵的逆转」的效果1回合只能使用1次。
-- ●从手卡把1只战士族·光属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·暗属性怪兽从卡组加入手卡。
-- ●从手卡把1只战士族·暗属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·光属性怪兽从卡组加入手卡。
function c3160805.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 可以从以下效果选择1个发动。「明与宵的逆转」的效果1回合只能使用1次。●从手卡把1只战士族·光属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·暗属性怪兽从卡组加入手卡。●从手卡把1只战士族·暗属性怪兽送去墓地。那之后，和那只怪兽相同等级的1只战士族·光属性怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3160805,0))  --"发动效果"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,3160805)
	e2:SetTarget(c3160805.target)
	e2:SetOperation(c3160805.operation)
	c:RegisterEffect(e2)
end
-- 作为第1个选项（光属性送墓、暗属性检索）的送墓怪兽过滤器：检查手卡中的怪兽是否为战士族·光属性，且卡组中存在1只可加入手卡的、与该怪兽等级相同的战士族·暗属性怪兽，以确定该手卡怪兽能被选择送去墓地。
function c3160805.tgfilter1(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 该条件进一步检查卡组中是否存在满足thfilter1（等级相同、战士族、暗属性、可加入手卡）的怪兽，作为手卡中这张战士族·光属性怪兽能够成为送墓对象的可行性前提。
		and Duel.IsExistingMatchingCard(c3160805.thfilter1,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 定义第1个选项的检索目标过滤器：从卡组选择1只等级与已送墓怪兽相同、战士族·暗属性且可以加入手卡的怪兽。
function c3160805.thfilter1(c,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 作为第2个选项（暗属性送墓、光属性检索）的送墓怪兽过滤器：检查手卡中的怪兽是否为战士族·暗属性，且卡组中存在1只可加入手卡的、与该怪兽等级相同的战士族·光属性怪兽，以确定该手卡怪兽能被选择送去墓地。
function c3160805.tgfilter2(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 该条件进一步检查卡组中是否存在满足thfilter2（等级相同、战士族、光属性、可加入手卡）的怪兽，作为手卡中这张战士族·暗属性怪兽能够成为送墓对象的可行性前提。
		and Duel.IsExistingMatchingCard(c3160805.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 定义第2个选项的检索目标过滤器：从卡组选择1只等级与已送墓怪兽相同、战士族·光属性且可以加入手卡的怪兽。
function c3160805.thfilter2(c,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 发动时的目标判断与分支选择：判断两个分支（光送墓暗检索／暗送墓光检索）是否分别可行，让玩家选择发动哪个分支，将选择结果存入效果Label，并向系统登记本次效果可能执行的送墓与检索操作。
function c3160805.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只满足第1分支送墓条件的战士族·光属性怪兽（且卡组中存在对应的暗属性检索目标），作为第1分支是否可选的标志。
	local b1=Duel.IsExistingMatchingCard(c3160805.tgfilter1,tp,LOCATION_HAND,0,1,nil,tp)
	-- 检查手卡中是否存在至少1只满足第2分支送墓条件的战士族·暗属性怪兽（且卡组中存在对应的光属性检索目标），作为第2分支是否可选的标志。
	local b2=Duel.IsExistingMatchingCard(c3160805.tgfilter2,tp,LOCATION_HAND,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个分支都可用时，让玩家选择“光属性怪兽送去墓地，暗属性怪兽加入手卡”或“暗属性怪兽送去墓地，光属性怪兽加入手卡”，返回0或1作为分支编号。
		op=Duel.SelectOption(tp,aux.Stringid(3160805,2),aux.Stringid(3160805,3))  --"光属性怪兽送去墓地，暗属性怪兽加入手卡/暗属性怪兽送去墓地，光属性怪兽加入手卡"
	elseif b1 then
		-- 当只有第1分支可用时，直接让玩家选择该分支，返回0即表示执行第1分支。
		op=Duel.SelectOption(tp,aux.Stringid(3160805,2))  --"光属性怪兽送去墓地，暗属性怪兽加入手卡"
	else
		-- 当只有第2分支可用时，让玩家选择该分支，由于只有一个选项时SelectOption返回0，因此加1使Label统一为1，表示执行第2分支。
		op=Duel.SelectOption(tp,aux.Stringid(3160805,3))+1  --"暗属性怪兽送去墓地，光属性怪兽加入手卡"
	end
	e:SetLabel(op)
	-- 设置操作信息：本次效果可能会把1张手卡送去墓地，供连锁响应对效果类别进行检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本次效果可能会从卡组把1张卡加入手卡，供连锁响应对效果类别进行检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：根据发动时选择并记录在Label中的分支编号执行对应操作，即先选择符合条件的怪兽从手卡送去墓地，若送墓成功则中断连锁时点，再从卡组检索相同等级且对应属性的战士族怪兽加入手卡，并向对方确认。
function c3160805.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 弹出手牌选择提示，提示玩家“请选择要送去墓地的卡”（第1分支）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从手卡选择1张满足tgfilter1（战士族·光属性且卡组有对应暗属性检索目标）的怪兽送去墓地。
		local g=Duel.SelectMatchingCard(tp,c3160805.tgfilter1,tp,LOCATION_HAND,0,1,1,nil,tp)
		-- 将选择的卡送入墓地，并判断实际送墓数量是否不为0；只有送墓成功才继续执行后续检索，对应效果原文的“那之后”。
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续“从卡组加入手卡”的检索处理与刚才的送墓处理不在同一时点，避免错时点。
			Duel.BreakEffect()
			-- 提示玩家选择要加入手卡的卡（从卡组检索时的选择提示）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1张满足thfilter1（等级与已送墓怪兽相同、战士族、暗属性、可以加入手卡）的怪兽。
			local tg=Duel.SelectMatchingCard(tp,c3160805.thfilter1,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst():GetLevel())
			-- 将检索到的卡加入其持有者的手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方玩家确认从卡组检索加入手卡的卡，完成检索的公开确认。
			Duel.ConfirmCards(1-tp,tg)
		end
	else
		-- 弹出手牌选择提示，提示玩家“请选择要送去墓地的卡”（第2分支）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从手卡选择1张满足tgfilter2（战士族·暗属性且卡组有对应光属性检索目标）的怪兽送去墓地。
		local g=Duel.SelectMatchingCard(tp,c3160805.tgfilter2,tp,LOCATION_HAND,0,1,1,nil,tp)
		-- 将选择的卡送入墓地，并判断实际送墓数量是否不为0；只有送墓成功才继续执行后续检索。
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续“从卡组加入手卡”的检索处理与送墓处理不在同一时点，避免错时点。
			Duel.BreakEffect()
			-- 提示玩家选择要加入手卡的卡（从卡组检索时的选择提示）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1张满足thfilter2（等级与已送墓怪兽相同、战士族、光属性、可以加入手卡）的怪兽。
			local tg=Duel.SelectMatchingCard(tp,c3160805.thfilter2,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst():GetLevel())
			-- 将检索到的卡加入其持有者的手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方玩家确认从卡组检索加入手卡的卡，完成检索的公开确认。
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
