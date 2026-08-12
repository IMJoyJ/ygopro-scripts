--リチュア・エリアル
-- 效果：
-- 反转：可以从卡组把1只名字带有「遗式」的怪兽加入手卡。
function c92784374.initial_effect(c)
	-- 反转：可以从卡组把1只名字带有「遗式」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92784374,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c92784374.tg)
	e1:SetOperation(c92784374.op)
	c:RegisterEffect(e1)
end
-- 过滤卡组中名字带有「遗式」且可以加入手卡的怪兽
function c92784374.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标确认与操作信息设置
function c92784374.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92784374.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c92784374.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c92784374.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
