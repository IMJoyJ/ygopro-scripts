--影六武衆－キザル
-- 效果：
-- ①：这张卡特殊召唤成功时才能发动。自己场上存在的属性以外的1只「六武众」怪兽从卡组加入手卡。
-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c6579928.initial_effect(c)
	-- ①：这张卡特殊召唤成功时才能发动。自己场上存在的属性以外的1只「六武众」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6579928,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c6579928.thtg)
	e1:SetOperation(c6579928.thop)
	c:RegisterEffect(e1)
	-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c6579928.reptg)
	e2:SetValue(c6579928.repval)
	e2:SetOperation(c6579928.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在指定属性的表侧表示怪兽
function c6579928.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 过滤函数：检索卡组中属性与自己场上已有属性不同的「六武众」怪兽
function c6579928.thfilter(c,tp)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 过滤条件：自己场上不存在与该卡相同属性的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(c6579928.filter,tp,LOCATION_MZONE,0,1,nil,c:GetAttribute())
end
-- 效果①的发动准备：检查卡组中是否存在可检索的怪兽，并设置操作信息
function c6579928.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「六武众」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6579928.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：将1张卡从卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1只满足条件的「六武众」怪兽加入手卡并展示
function c6579928.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「六武众」怪兽
	local g=Duel.SelectMatchingCard(tp,c6579928.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：自己场上因效果破坏且非代替破坏的表侧表示「六武众」怪兽
function c6579928.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动准备：检查墓地的此卡是否可除外，且被破坏的怪兽是否仅有1只自己场上的「六武众」怪兽
function c6579928.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c6579928.repfilter,1,nil,tp)
		and eg:GetCount()==1 end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的价值函数：确定被破坏的卡是否符合代替破坏的过滤条件
function c6579928.repval(e,c)
	return c6579928.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理：将墓地的这张卡除外
function c6579928.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
