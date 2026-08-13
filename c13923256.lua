--戦華の妙－魯敬
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，从自己墓地选和那张卡卡名不同的1张「战华」魔法·陷阱卡加入手卡。
-- ②：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c13923256.initial_effect(c)
	-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，从自己墓地选和那张卡卡名不同的1张「战华」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13923256,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,13923256)
	e1:SetTarget(c13923256.thtg)
	e1:SetOperation(c13923256.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13923256,1))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13923257)
	e3:SetCondition(c13923256.descon)
	e3:SetTarget(c13923256.destg)
	e3:SetOperation(c13923256.desop)
	c:RegisterEffect(e3)
end
-- ①效果选择对象的筛选条件：自己场上的表侧表示永续魔法·陷阱卡，且可送去墓地，并且自己墓地存在卡名不同的「战华」魔法·陷阱卡可加入手卡。
function c13923256.tgfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGrave()
		-- 进一步确认自己墓地存在符合条件的「战华」魔法·陷阱卡（与对象卡卡名不同且能加入手卡），作为①效果可发动的追加条件。
		and Duel.IsExistingMatchingCard(c13923256.thfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 检索用过滤条件：自己墓地中的「战华」魔法·陷阱卡，能够加入手卡，且卡名与送墓的那张对象卡不同。
function c13923256.thfilter(c,code)
	return c:IsSetCard(0x137) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and not c:IsCode(code)
end
-- ①效果发动时的处理：检查能否选择对象；选择自己场上1张永续魔法·陷阱卡为对象，并设置送去墓地与从墓地加入手卡的处理信息。
function c13923256.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c13923256.tgfilter(chkc,tp) end
	-- 非处理时的发动判定：检查自己场上是否存在1张满足条件的永续魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c13923256.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己场上1张符合条件的永续魔法·陷阱卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c13923256.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将已选择的对象登记为“送去墓地”的处理对象，用于效果处理时的连锁判定和结算。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置“从墓地选1张卡加入手卡”的操作信息，目标为玩家自己墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理时：把对象卡送去墓地；若成功且该卡在墓地，则从自己墓地选择1张卡名不同的「战华」魔法·陷阱卡加入手卡，并给对方确认。
function c13923256.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与该效果关联，然后将其送去墓地；只有成功送墓且该卡在墓地时，才继续执行加入手卡的处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 弹出选择提示，让玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己墓地选择1张「战华」魔法·陷阱卡，要求与送墓的卡卡名不同且能加入手卡，并考虑王家长眠之谷的影响。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13923256.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选中的卡加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的触发条件：自己场上的其他「战华」怪兽发动效果时，此卡可以发动（且该效果是怪兽效果，操作者为自己）。
function c13923256.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x137) and rp==tp and re:GetHandler()~=e:GetHandler()
end
-- ②效果发动时的处理：检查对方场上是否有魔法·陷阱卡可作为对象；选择对方场上1张魔法·陷阱卡为对象，并设置破坏信息。
function c13923256.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 非处理时的发动判定：检查对方场上是否存在1张魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 弹出选择提示，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张魔法·陷阱卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置破坏的处理信息：破坏对象为选中的那张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理时：若对象卡仍与该效果关联，则将其破坏。
function c13923256.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏那张对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
