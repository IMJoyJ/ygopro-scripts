--スプリガンズ・ウォッチ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「大沙海 黄金戈尔工达」加入手卡。自己的场地区域有「大沙海 黄金戈尔工达」存在的场合，可以作为代替让以下效果适用。
-- ●从卡组把1只「护宝炮妖」怪兽加入手卡，从卡组把1只「护宝炮妖」怪兽送去墓地。
function c23499963.initial_effect(c)
	-- 将卡号60884672（「大沙海 黄金戈尔工达」）记录到本卡的“记载卡名”列表中，使规则上视为本卡提及该卡名，用于后续检索等判定。
	aux.AddCodeList(c,60884672)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1张「大沙海 黄金戈尔工达」加入手卡。自己的场地区域有「大沙海 黄金戈尔工达」存在的场合，可以作为代替让以下效果适用。●从卡组把1只「护宝炮妖」怪兽加入手卡，从卡组把1只「护宝炮妖」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23499963+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23499963.target)
	e1:SetOperation(c23499963.activate)
	c:RegisterEffect(e1)
end
-- 定义检索「大沙海 黄金戈尔工达」的过滤条件：卡名必须是60884672且能够加入手卡。
function c23499963.filter(c)
	return c:IsCode(60884672) and c:IsAbleToHand()
end
-- 定义“检索并送墓「护宝炮妖」怪兽”这一替代操作中用于选择加入手卡的怪兽的过滤条件：必须是「护宝炮妖」系列怪兽且能加入手卡，同时卡组中还存在另一只可送去墓地的「护宝炮妖」怪兽，以保证替代效果的两步能够完成。
function c23499963.thfilter(c,tp)
	-- 判断该「护宝炮妖」怪兽是否满足作为检索目标的条件：属于0x155系列、是怪兽卡、可加入手卡，且卡组中还存在除自身以外可供送墓的「护宝炮妖」怪兽。
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(c23499963.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 定义「护宝炮妖」怪兽的送墓过滤条件：属于0x155系列、是怪兽卡且能够被效果送去墓地。
function c23499963.tgfilter(c)
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义效果发动时的合法性与操作信息登记：在chk检查时，确认卡组有「大沙海 黄金戈尔工达」可检索，或场地区有该场地且存在可执行替代检索/送墓的「护宝炮妖」组合；同时登记可能发生的加入手卡和送去墓地操作信息。
function c23499963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己的场地区域是否存在表侧表示的「大沙海 黄金戈尔工达」（或视为该场地卡的环境），结果赋给变量b，用于判断是否满足发动替代效果的条件。
	local b=Duel.IsEnvironment(60884672,tp,LOCATION_FZONE)
	-- 在效果发动合法性检查（chk==0）时，判断是否至少满足以下一项：卡组存在「大沙海 黄金戈尔工达」可加入手卡；或场地区有该场地且存在可检索并送墓的「护宝炮妖」组合，若均不满足则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23499963.filter,tp,LOCATION_DECK,0,1,nil) or b and Duel.IsExistingMatchingCard(c23499963.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：本次连锁将把1张卡从卡组加入手卡，用于连锁判定中以“检索效果”被正确识别。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次连锁可能将卡从卡组送去墓地，预计数量为0，用于“送去墓地”相关检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
-- 定义效果处理时的执行逻辑：先判断场地区是否有「大沙海 黄金戈尔工达」以及是否有可用的「护宝炮妖」组合，并根据玩家选择决定执行“检索「护宝炮妖」怪兽并送墓”的替代效果，还是执行“检索「大沙海 黄金戈尔工达」”的通常效果。
function c23499963.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的场地区是否存在「大沙海 黄金戈尔工达」，避免以发动时的状态代替处理时的状态。
	local b=Duel.IsEnvironment(60884672,tp,LOCATION_FZONE)
	-- 判断是否进入替代效果分支：场地区有该场地，且卡组有可检索并可送墓的「护宝炮妖」怪兽组合，同时（没有「大沙海 黄金戈尔工达」可检索，或玩家选择“是”）时，执行替代效果。
	if b and Duel.IsExistingMatchingCard(c23499963.thfilter,tp,LOCATION_DECK,0,1,nil,tp) and (not Duel.IsExistingMatchingCard(c23499963.filter,tp,LOCATION_DECK,0,1,nil) or Duel.SelectYesNo(tp,aux.Stringid(23499963,0))) then  --"是否检索「护宝炮妖」怪兽？"
		-- 给出选择手卡对象的提示消息，告知玩家正在选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只满足thfilter条件的「护宝炮妖」怪兽，准备加入手卡。
		local g=Duel.SelectMatchingCard(tp,c23499963.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		-- 将被选择的「护宝炮妖」怪兽以效果原因加入手卡；只有实际加入手卡成功且该卡仍处于手牌时，才继续后续的送墓操作。
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			-- 将刚刚检索到的「护宝炮妖」怪兽展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
			-- 给出选择送墓对象的提示消息，告知玩家正在选择要送去墓地的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让玩家从卡组选择1只满足tgfilter条件的「护宝炮妖」怪兽，用于送去墓地。
			local tg=Duel.SelectMatchingCard(tp,c23499963.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的「护宝炮妖」怪兽以效果原因送去墓地。
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	else
		-- 在通常效果分支中，给出选择加入手卡对象的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足filter条件的「大沙海 黄金戈尔工达」，准备加入手卡。
		local g=Duel.SelectMatchingCard(tp,c23499963.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「大沙海 黄金戈尔工达」以效果原因加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将检索到的「大沙海 黄金戈尔工达」展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
