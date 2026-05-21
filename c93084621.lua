--破械神アルバ
-- 效果：
-- 包含「破械神」怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。只用那只对方怪兽和自己场上的这张卡为素材把「破械神 阿罗魃」以外的1只暗属性连接怪兽连接召唤。
-- ②：场上的这张卡被战斗·效果破坏的场合，以「破械神 阿罗魃」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
function c93084621.initial_effect(c)
	-- 添加连接召唤手续：需要2只以上怪兽作为素材，且必须包含「破械神」怪兽
	aux.AddLinkProcedure(c,nil,2,nil,c93084621.lcheck)
	c:EnableReviveLimit()
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。只用那只对方怪兽和自己场上的这张卡为素材把「破械神 阿罗魃」以外的1只暗属性连接怪兽连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93084621,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93084621)
	e1:SetTarget(c93084621.target)
	e1:SetOperation(c93084621.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，以「破械神 阿罗魃」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93084621,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,93084622)
	e2:SetCondition(c93084621.thcon)
	e2:SetTarget(c93084621.thtg)
	e2:SetOperation(c93084621.thop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤：素材组中必须包含至少1张「破械神」怪兽
function c93084621.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1130)
end
-- 效果①的对象过滤：对方场上表侧表示的怪兽，且能与自身作为素材连接召唤额外卡组的暗属性连接怪兽
function c93084621.tgfilter(c,tp,ec)
	local mg=Group.FromCards(ec,c)
	-- 检查该怪兽是否表侧表示，且额外卡组中是否存在以该怪兽和自身为素材可连接召唤的暗属性连接怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c93084621.lfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 额外卡组连接怪兽过滤：暗属性、非同名卡，且能以指定素材组进行连接召唤
function c93084621.lfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_DARK) and not c:IsCode(93084621) and c:IsLinkSummonable(mg,nil,2,2)
end
-- 效果①的发动准备：检查是否存在合法对象，进行取对象操作并设置特殊召唤的操作信息
function c93084621.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查对方场上是否存在满足过滤条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c93084621.tgfilter,tp,0,LOCATION_MZONE,1,nil,tp,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c93084621.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,tp,e:GetHandler())
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：验证自身与对象怪兽的状态，选择额外卡组中合法的暗属性连接怪兽并进行连接召唤
function c93084621.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
		local mg=Group.FromCards(c,tc)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的、可使用指定素材进行连接召唤的暗属性连接怪兽
		local g=Duel.SelectMatchingCard(tp,c93084621.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local lc=g:GetFirst()
		if lc then
			-- 使用指定的2只怪兽作为素材，将选定的怪兽进行连接召唤
			Duel.LinkSummon(tp,lc,mg,nil,2,2)
		end
	end
end
-- 效果②的发动条件：场上的这张卡被战斗或效果破坏
function c93084621.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的对象过滤：自己墓地中「破械神 阿罗魃」以外的、可以加入手牌的恶魔族怪兽
function c93084621.thfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsCode(93084621) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查墓地中是否存在合法的恶魔族怪兽，进行取对象操作并设置加入手牌的操作信息
function c93084621.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93084621.thfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的恶魔族怪兽
	if chk==0 then return Duel.IsExistingTarget(c93084621.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1只满足条件的恶魔族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93084621.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将选中的墓地怪兽加入手牌
function c93084621.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽通过效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
