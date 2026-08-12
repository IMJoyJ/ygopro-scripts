--工作箱
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有怪兽存在的场合才能发动。从卡组把2张卡名不同的装备魔法卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组最下面。
function c70508653.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有怪兽存在的场合才能发动。从卡组把2张卡名不同的装备魔法卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,70508653)
	e2:SetCondition(c70508653.thcon)
	e2:SetTarget(c70508653.thtg)
	e2:SetOperation(c70508653.thop)
	c:RegisterEffect(e2)
end
-- 定义效果的发动条件函数
function c70508653.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
-- 过滤卡组中可以加入手卡的装备魔法卡
function c70508653.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 定义效果的发动准备（Target）函数
function c70508653.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有可以加入手卡的装备魔法卡
		local g=Duel.GetMatchingGroup(c70508653.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁的操作信息：将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 定义效果的处理（Operation）函数
function c70508653.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取卡组中所有可以加入手卡的装备魔法卡
	local g=Duel.GetMatchingGroup(c70508653.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从卡组中筛选出2张卡名不同的装备魔法卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的2张卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的那1张卡加入自己的手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		local tc2=(sg-tg):GetFirst()
		-- 将剩下的那1张卡移动到卡组最下方
		Duel.MoveSequence(tc2,SEQ_DECKBOTTOM)
	end
end
