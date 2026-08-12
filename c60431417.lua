--黄昏の双龍
-- 效果：
-- ①：自己场上有「惩戒之龙」存在的场合，以自己墓地1只「裁决之龙」为对象才能发动。那只怪兽加入手卡。那之后，从自己卡组上面把4张卡送去墓地。
-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合，以自己墓地1只「惩戒之龙」为对象才能发动。那只怪兽加入手卡。那之后，从自己卡组上面把4张卡除外。
function c60431417.initial_effect(c)
	-- ①：自己场上有「惩戒之龙」存在的场合，以自己墓地1只「裁决之龙」为对象才能发动。那只怪兽加入手卡。那之后，从自己卡组上面把4张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c60431417.condition)
	e1:SetTarget(c60431417.target)
	e1:SetOperation(c60431417.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合，以自己墓地1只「惩戒之龙」为对象才能发动。那只怪兽加入手卡。那之后，从自己卡组上面把4张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c60431417.thcon)
	e2:SetTarget(c60431417.thtg)
	e2:SetOperation(c60431417.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的「惩戒之龙」
function c60431417.cfilter(c)
	return c:IsFaceup() and c:IsCode(19959563)
end
-- ①号效果的发动条件：自己场上存在「惩戒之龙」
function c60431417.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「惩戒之龙」
	return Duel.IsExistingMatchingCard(c60431417.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查墓地中是否存在可以加入手卡的「裁决之龙」
function c60431417.filter(c)
	return c:IsCode(57774843) and c:IsAbleToHand()
end
-- ①号效果的发动准备：检查并选择墓地的「裁决之龙」作为对象，且自身卡组数量足够送去墓地
function c60431417.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c60431417.filter(chkc) end
	-- 在效果发动阶段（chk==0）检查墓地是否存在可作为对象的「裁决之龙」
	if chk==0 then return Duel.IsExistingTarget(c60431417.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且检查玩家是否能将卡组顶部的4张卡送去墓地
		and Duel.IsPlayerCanDiscardDeck(tp,4) end
	-- 提示玩家选择要加入手卡的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中1只「裁决之龙」作为效果的对象
	local g=Duel.SelectTarget(tp,c60431417.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置当前连锁的操作信息：从卡组将4张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
-- ①号效果的处理：将作为对象的怪兽加入手卡，那之后将卡组顶部的4张卡送去墓地
function c60431417.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合效果，则将其加入手卡，并判断是否成功加入
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的送去墓地处理不与加入手卡同时进行（造成错时点）
		Duel.BreakEffect()
		-- 将自己卡组顶部的4张卡送去墓地
		Duel.DiscardDeck(tp,4,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：这张卡被「光道」怪兽的效果从卡组送去墓地
function c60431417.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x38)
		and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数：检查墓地中是否存在可以加入手卡的「惩戒之龙」
function c60431417.thfilter(c)
	return c:IsCode(19959563) and c:IsAbleToHand()
end
-- ②号效果的发动准备：检查并选择墓地的「惩戒之龙」作为对象，且自身卡组顶部的4张卡可以被除外
function c60431417.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c60431417.thfilter(chkc) end
	-- 获取自己卡组顶部的4张卡
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 在效果发动阶段（chk==0）检查墓地是否存在可作为对象的「惩戒之龙」
	if chk==0 then return Duel.IsExistingTarget(c60431417.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and rg:FilterCount(Card.IsAbleToRemove,nil)==4 end
	-- 提示玩家选择要加入手卡的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中1只「惩戒之龙」作为效果的对象
	local g=Duel.SelectTarget(tp,c60431417.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置当前连锁的操作信息：将卡组顶部的4张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,4,0,0)
end
-- ②号效果的处理：将作为对象的怪兽加入手卡，那之后将卡组顶部的4张卡除外
function c60431417.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合效果，则将其加入手卡，并判断是否成功加入
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的除外处理不与加入手卡同时进行（造成错时点）
		Duel.BreakEffect()
		-- 获取自己卡组顶部的4张卡
		local rg=Duel.GetDecktopGroup(tp,4)
		-- 使接下来的操作不进行洗牌检测（防止在除外卡组顶部的卡时自动洗牌）
		Duel.DisableShuffleCheck()
		-- 将获取到的卡组顶部的4张卡以表侧表示除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
