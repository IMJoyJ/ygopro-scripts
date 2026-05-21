--力天使ヴァルキリア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己把怪兽的效果·魔法·陷阱卡的发动无效的场合发动。从卡组把1只天使族·光属性怪兽加入手卡。
function c89055154.initial_effect(c)
	-- ①：自己把怪兽的效果·魔法·陷阱卡的发动无效的场合发动。从卡组把1只天使族·光属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89055154,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,89055154)
	e3:SetCondition(c89055154.thcon)
	e3:SetTarget(c89055154.thtg)
	e3:SetOperation(c89055154.thop)
	c:RegisterEffect(e3)
end
-- 效果1的Condition函数：判断是否是自己将怪兽的效果、魔法或陷阱卡的发动无效
function c89055154.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取无效当前连锁的玩家
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
	return dp==tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 过滤函数：卡组中天使族·光属性且能加入手卡的怪兽
function c89055154.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果1的Target函数：确定效果分类为检索并设置操作信息
function c89055154.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的Operation函数：从卡组选择1只天使族·光属性怪兽加入手卡
function c89055154.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的天使族·光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c89055154.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
