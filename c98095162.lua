--ライトロード・ドミニオン キュリオス
-- 效果：
-- 相同属性而种族不同的怪兽3只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组选1张卡送去墓地。
-- ②：自己卡组的卡被效果送去墓地的场合发动。从自己卡组上面把3张卡送去墓地。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
function c98095162.initial_effect(c)
	-- 设置连接召唤的手续，需要3只怪兽作为素材，并使用自定义过滤函数进行检测
	aux.AddLinkProcedure(c,nil,3,3,c98095162.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组选1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98095162,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,98095162)
	e1:SetCondition(c98095162.tgcon)
	e1:SetTarget(c98095162.tgtg)
	e1:SetOperation(c98095162.tgop)
	c:RegisterEffect(e1)
	-- ②：自己卡组的卡被效果送去墓地的场合发动。从自己卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98095162,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,98095163)
	e2:SetCondition(c98095162.ddcon)
	e2:SetTarget(c98095162.ddtg)
	e2:SetOperation(c98095162.ddop)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98095162,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c98095162.thcon)
	e3:SetTarget(c98095162.thtg)
	e3:SetOperation(c98095162.thop)
	c:RegisterEffect(e3)
end
-- 连接召唤素材的检测函数，用于判断素材是否满足“相同属性而种族不同”的条件
function c98095162.lcheck(g)
	local tc=g:GetFirst()
	-- 检查素材怪兽的属性是否全部相同，且种族各不相同（种族种类数量等于素材数量）
	return aux.SameValueCheck(g,Card.GetLinkAttribute) and g:GetClassCount(Card.GetLinkRace)==#g
end
-- 效果①的发动条件：此卡是连接召唤成功的
function c98095162.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的靶向/发动准备函数：检查卡组是否有可送去墓地的卡，并设置送去墓地的操作信息
function c98095162.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会从自己卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张卡送去墓地
function c98095162.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张可以送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数：用于检测送去墓地的卡原本是否在自己的卡组
function c98095162.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 效果②的发动条件：自己卡组的卡因效果被送去墓地
function c98095162.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and eg:IsExists(c98095162.cfilter,1,nil,tp)
end
-- 效果②的靶向/发动准备函数：设置卡组破坏（送去墓地）的操作信息
function c98095162.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会从自己卡组上面将3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果②的效果处理：将自己卡组最上方的3张卡送去墓地
function c98095162.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将自己卡组最上方的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
-- 效果③的发动条件：表侧表示的此卡因战斗破坏，或者因对方的效果从自己场上离开
function c98095162.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果③的靶向/发动准备函数：选择自己墓地1张卡作为对象，并设置加入手卡的操作信息
function c98095162.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToHand() end
	-- 检查自己墓地是否存在至少1张可以加入手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1张可以加入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示此效果会将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将作为对象的卡加入手卡
function c98095162.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
