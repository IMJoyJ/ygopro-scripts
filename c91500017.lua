--トゥーンのしおり
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把1张「卡通书签」以外的有「卡通世界」的卡名记述的卡或者「卡通世界」从卡组加入手卡。
-- ②：自己场上的「卡通世界」被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c91500017.initial_effect(c)
	-- 注册卡片记述了「卡通世界」的卡片密码
	aux.AddCodeList(c,15259703)
	-- 这个卡名的卡在1回合只能发动1张。①：把1张「卡通书签」以外的有「卡通世界」的卡名记述的卡或者「卡通世界」从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,91500017+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c91500017.target)
	e1:SetOperation(c91500017.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「卡通世界」被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c91500017.reptg)
	e2:SetValue(c91500017.repval)
	e2:SetOperation(c91500017.repop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「卡通书签」以外、记述了「卡通世界」或卡名为「卡通世界」且能加入手牌的卡
function c91500017.filter(c)
	-- 检查卡片是否是「卡通书签」以外、记述了「卡通世界」或卡名为「卡通世界」且能加入手牌
	return aux.IsCodeOrListed(c,15259703) and not c:IsCode(91500017) and c:IsAbleToHand()
end
-- ①号效果的发动准备（检查卡组中是否存在符合条件的卡，并设置操作信息）
function c91500017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91500017.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理（从卡组选择1张符合条件的卡加入手牌并给对方确认）
function c91500017.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c91500017.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上因效果破坏的「卡通世界」
function c91500017.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsCode(15259703)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标检查与玩家意愿确认
function c91500017.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c91500017.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏效果的适用对象
function c91500017.repval(e,c)
	return c91500017.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的具体操作（将墓地的这张卡除外）
function c91500017.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
