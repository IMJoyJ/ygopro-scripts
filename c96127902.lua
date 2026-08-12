--かなり魅湧な受注水産
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地1张卡为对象才能发动。那张卡除外。那之后，可以把1张那张卡的同名卡从卡组加入手卡。
local s,id,o=GetID()
-- 注册魔法卡发动效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方墓地1张卡为对象才能发动。那张卡除外。那之后，可以把1张那张卡的同名卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在发动阶段检测对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为除外目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 过滤卡组中与除外卡片同名且可以加入手牌的卡片
function s.filter(c,...)
	return c:IsCode(...) and c:IsAbleToHand()
end
-- 效果处理函数，首先获取对象卡片并尝试将其除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡片是否仍与效果相关，并将其表侧表示除外
	if not (tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_REMOVED)) then return end
	-- 获取卡组中与被除外卡片同名的卡片组
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,tc:GetCode())
	-- 若卡组中存在同名卡，询问玩家是否将其加入手牌
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把和除外的卡同名的卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续的检索手牌处理不与除外同时进行
		Duel.BreakEffect()
		-- 将选择的同名卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
