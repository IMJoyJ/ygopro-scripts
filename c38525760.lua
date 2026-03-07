--陽炎獣 サーベラス
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000。只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，这张卡被破坏送去墓地时，可以从卡组把1张名字带有「阳炎」的卡加入手卡。
function c38525760.initial_effect(c)
	-- 对方不能把这张卡作为卡的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果为不会成为对方的卡的效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38525760,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c38525760.ntcon)
	e2:SetOperation(c38525760.ntop)
	c:RegisterEffect(e2)
	-- 卡组检索
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
-- 召唤条件：不需解放，等级5以上，且场上存在空位
function c38525760.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足召唤条件：不需解放，等级5以上，且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤时将原本攻击力设置为1000
function c38525760.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 将原本攻击力设置为1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 被破坏送去墓地时发动
function c38525760.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数：检索卡组中名字带有「阳炎」的卡
function c38525760.filter(c)
	return c:IsSetCard(0x7d) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息
function c38525760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38525760.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1张卡加入手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果
function c38525760.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c38525760.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
