--ギアギアーマー
-- 效果：
-- 这张卡1回合只有1次可以变成里侧守备表示。这张卡反转时，可以从卡组把「齿轮齿轮铠甲人」以外的1只名字带有「齿轮齿轮」的怪兽加入手卡。
function c923596.initial_effect(c)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(923596,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c923596.target)
	e1:SetOperation(c923596.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，可以从卡组把「齿轮齿轮铠甲人」以外的1只名字带有「齿轮齿轮」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(923596,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c923596.shtg)
	e2:SetOperation(c923596.shop)
	c:RegisterEffect(e2)
end
-- 变成里侧守备表示效果的发动准备，检查是否能改变表示形式并注册1回合1次限制
function c923596.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(923596)==0 end
	c:RegisterFlagEffect(923596,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息为将自身改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的处理
function c923596.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤卡组中「齿轮齿轮铠甲人」以外的名字带有「齿轮齿轮」的怪兽
function c923596.filter(c)
	return c:IsSetCard(0x72) and not c:IsCode(923596) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 反转检索效果的发动准备
function c923596.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c923596.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 反转检索效果的处理
function c923596.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c923596.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
