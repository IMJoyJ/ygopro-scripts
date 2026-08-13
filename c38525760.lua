--陽炎獣 サーベラス
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000。只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，这张卡被破坏送去墓地时，可以从卡组把1张名字带有「阳炎」的卡加入手卡。
function c38525760.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果的Value为aux.tgoval，用于判断对方不能把这张卡作为效果对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38525760,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c38525760.ntcon)
	e2:SetOperation(c38525760.ntop)
	c:RegisterEffect(e2)
	-- 此外，这张卡被破坏送去墓地时，可以从卡组把1张名字带有「阳炎」的卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38525760,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c38525760.thcon)
	e3:SetTarget(c38525760.thtg)
	e3:SetOperation(c38525760.thop)
	c:RegisterEffect(e3)
end
-- 定义无解放召唤的规则条件：c为空时视为可用；否则需要满足无解放、等级5以上、我方怪兽区有空位。
function c38525760.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否为无解放召唤：满足未解放（minc==0）、等级不低于5、有可用怪兽区。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 定义无解放召唤成功时的处理：给这张卡注册一个效果，将其原本攻击力变为1000，并在离开场上后重置。
function c38525760.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的这张卡的原本攻击力变成1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 定义检索效果的触发条件：这张卡被破坏并送去墓地。
function c38525760.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 定义检索的过滤条件：卡名含有「阳炎」字段，并且可以被加入手卡。
function c38525760.filter(c)
	return c:IsSetCard(0x7d) and c:IsAbleToHand()
end
-- 定义检索效果发动时的目标处理：若卡组存在符合条件的「阳炎」卡，则设置从卡组将1张加入手卡的操作信息。
function c38525760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查卡组是否存在1张以上满足条件的「阳炎」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38525760.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：从卡组将1张卡加入手卡（数量1，持有者为tp，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果处理：提示选择要加入手卡的卡，从卡组选1张符合条件的「阳炎」卡，加入手牌并向对方确认。
function c38525760.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让操作玩家从卡组选择1张满足条件的「阳炎」卡。
	local g=Duel.SelectMatchingCard(tp,c38525760.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
