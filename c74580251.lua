--セフィラの神意
-- 效果：
-- 「神数的神意」在1回合只能发动1张。
-- ①：从卡组把「神数的神意」以外的1张「神数」卡加入手卡。
-- ②：自己场上的「神数」卡被破坏的场合，可以作为代替把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
function c74580251.initial_effect(c)
	-- ①：从卡组把「神数的神意」以外的1张「神数」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,74580251+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c74580251.target)
	e1:SetOperation(c74580251.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「神数」卡被破坏的场合，可以作为代替把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c74580251.reptg)
	e2:SetValue(c74580251.repval)
	e2:SetOperation(c74580251.repop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「神数的神意」以外的「神数」卡片并判断是否能加入手卡
function c74580251.filter(c)
	return c:IsSetCard(0xc4) and not c:IsCode(74580251) and c:IsAbleToHand()
end
-- ①号效果的发动准备与检测函数
function c74580251.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c74580251.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理函数
function c74580251.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c74580251.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片通过效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上因战斗或效果被破坏的表侧表示「神数」卡片
function c74580251.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc4) and c:IsOnField()
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的检测与选择是否发动的处理函数
function c74580251.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自身是否能除外、是否不在送去墓地的回合，以及场上是否有「神数」卡被破坏
	if chk==0 then return e:GetHandler():IsAbleToRemove() and aux.exccon(e) and eg:IsExists(c74580251.repfilter,1,nil,tp) end
	-- 询问玩家是否使用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定被破坏的卡片是否符合代替破坏的过滤条件
function c74580251.repval(e,c)
	return c74580251.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的实际执行函数
function c74580251.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外作为代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
