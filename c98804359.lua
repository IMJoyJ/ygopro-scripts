--海竜神の激昂
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「激流葬」加入手卡。
-- ②：自己场上的水属性怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c98804359.initial_effect(c)
	-- ①：从卡组把1张「激流葬」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98804359,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,98804359)
	e1:SetTarget(c98804359.target)
	e1:SetOperation(c98804359.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的水属性怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,98804360)
	e2:SetTarget(c98804359.reptg)
	e2:SetValue(c98804359.repval)
	c:RegisterEffect(e2)
end
-- 过滤卡组中卡名为「激流葬」且能加入手牌的卡片
function c98804359.filter(c)
	return c:IsCode(53582587) and c:IsAbleToHand()
end
-- ①号效果的发动准备与合法性检测函数
function c98804359.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测己方卡组是否存在至少1张可以加入手牌的「激流葬」
	if chk==0 then return Duel.IsExistingMatchingCard(c98804359.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将卡组的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的效果处理函数（检索「激流葬」并加入手牌）
function c98804359.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组选择1张满足过滤条件的「激流葬」
	local g=Duel.SelectMatchingCard(tp,c98804359.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤己方场上因效果破坏且不处于代替破坏状态的表侧表示水属性怪兽
function c98804359.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②号代替破坏效果的检测与处理函数
function c98804359.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c98804359.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将墓地的这张卡因效果表侧表示除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 确定被代替破坏的怪兽是否符合过滤条件
function c98804359.repval(e,c)
	return c98804359.repfilter(c,e:GetHandlerPlayer())
end
