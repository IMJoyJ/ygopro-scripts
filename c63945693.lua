--虹の架け橋
-- 效果：
-- ①：从卡组把1张「宝玉」魔法·陷阱卡加入手卡。
function c63945693.initial_effect(c)
	-- ①：从卡组把1张「宝玉」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63945693.target)
	e1:SetOperation(c63945693.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中属于「宝玉」字段的魔法·陷阱卡，且该卡能加入手卡
function c63945693.filter(c)
	return c:IsSetCard(0x34) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的落点检测与操作信息设置
function c63945693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「宝玉」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c63945693.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择「宝玉」魔法·陷阱卡加入手卡并给对方确认
function c63945693.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动效果的玩家从卡组选择1张满足过滤条件的「宝玉」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c63945693.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
