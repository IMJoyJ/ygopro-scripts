--神秘の代行者 アース
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「神秘之代行者 厄斯」以外的1只「代行者」怪兽加入手卡。场上有「天空的圣域」存在的场合，可以把加入手卡的怪兽改成1只「主宰者·许珀里翁」。
function c91188343.initial_effect(c)
	-- 在卡片中注册其记载了「天空的圣域」的卡片密码
	aux.AddCodeList(c,56433456)
	-- ①：这张卡召唤成功时才能发动。从卡组把「神秘之代行者 厄斯」以外的1只「代行者」怪兽加入手卡。场上有「天空的圣域」存在的场合，可以把加入手卡的怪兽改成1只「主宰者·许珀里翁」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91188343,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c91188343.tg)
	e1:SetOperation(c91188343.op)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「神秘之代行者 厄斯」以外的「代行者」怪兽的过滤条件
function c91188343.filter1(c)
	return c:IsSetCard(0x44) and not c:IsCode(91188343) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤卡组中「神秘之代行者 厄斯」以外的「代行者」怪兽或「主宰者·许珀里翁」的过滤条件
function c91188343.filter2(c)
	return ((c:IsSetCard(0x44) and not c:IsCode(91188343) and c:IsType(TYPE_MONSTER)) or c:IsCode(55794644)) and c:IsAbleToHand()
end
-- 效果发动的目标确认与合法性检查函数
function c91188343.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断场上是否存在「天空的圣域」
		if not Duel.IsEnvironment(56433456) then
			-- 若场上没有「天空的圣域」，则检查卡组中是否存在「神秘之代行者 厄斯」以外的「代行者」怪兽
			return Duel.IsExistingMatchingCard(c91188343.filter1,tp,LOCATION_DECK,0,1,nil) end
		-- 若场上有「天空的圣域」，则检查卡组中是否存在「神秘之代行者 厄斯」以外的「代行者」怪兽或「主宰者·许珀里翁」
		return Duel.IsExistingMatchingCard(c91188343.filter2,tp,LOCATION_DECK,0,1,nil)
	end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c91188343.op(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 向玩家发送选择加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 判断场上是否存在「天空的圣域」
	if not Duel.IsEnvironment(56433456) then
		-- 若场上没有「天空的圣域」，则从卡组选择1只「神秘之代行者 厄斯」以外的「代行者」怪兽
		g=Duel.SelectMatchingCard(tp,c91188343.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 若场上有「天空的圣域」，则从卡组选择1只「神秘之代行者 厄斯」以外的「代行者」怪兽或1只「主宰者·许珀里翁」
	else g=Duel.SelectMatchingCard(tp,c91188343.filter2,tp,LOCATION_DECK,0,1,1,nil) end
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
