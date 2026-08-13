--アクアアクトレス・テトラ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「水族馆」卡加入手卡。
function c39260991.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「水族馆」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c39260991.thtg)
	e1:SetOperation(c39260991.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否为「水族馆」字段的卡，并且该卡可以被加入手卡。
function c39260991.filter(c)
	return c:IsSetCard(0xce) and c:IsAbleToHand()
end
-- 发动时的目标判定与操作信息设置函数：在效果发动检查阶段确认是否满足发动条件，并登记本次效果将执行从卡组检索加入手牌的处理。
function c39260991.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：当chk==0时，确认卡组中存在至少1张满足filter条件的「水族馆」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39260991.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：向连锁信息中登记本次效果为从卡组将1张卡加入手牌（不取对象，数量为1，区域为卡组），供其他卡/效果响应判定时参考。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行发动时的实际操作，进行选卡提示、从卡组选择符合条件的卡加入手牌，并让对方确认。
function c39260991.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：向发动玩家显示‘请选择要加入手牌的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己的卡组中选择1张满足filter条件的「水族馆」卡（由于已确认存在，选1张）。
	local g=Duel.SelectMatchingCard(tp,c39260991.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去其持有者的手卡，即完成检索加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
