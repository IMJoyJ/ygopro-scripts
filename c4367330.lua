--十二獣ラビーナ
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 兔铳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡加入手卡。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡为对象的对方的魔法卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
function c4367330.initial_effect(c)
	-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 兔铳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4367330,0))  --"墓地「十二兽」卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c4367330.thcon)
	e1:SetTarget(c4367330.thtg)
	e1:SetOperation(c4367330.thop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡为对象的对方的魔法卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4367330,1))  --"魔法卡的效果发动无效（十二兽 兔铳）"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c4367330.discon)
	e2:SetCost(c4367330.discost)
	e2:SetTarget(c4367330.distg)
	e2:SetOperation(c4367330.disop)
	c:RegisterEffect(e2)
end
-- 判断破坏原因是否为效果或战斗破坏
function c4367330.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 筛选墓地中的十二兽卡，且不是兔铳本身，且可以加入手牌
function c4367330.thfilter(c)
	return c:IsSetCard(0xf1) and c:IsAbleToHand() and not c:IsCode(4367330)
end
-- 设置效果目标为满足条件的墓地十二兽卡
function c4367330.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4367330.thfilter(chkc) end
	-- 检查是否有满足条件的墓地十二兽卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c4367330.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地十二兽卡作为目标
	local g=Duel.SelectTarget(tp,c4367330.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将选中的墓地十二兽卡加入手牌
function c4367330.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断是否为兽战士族且未在战斗破坏状态，且对方发动的是魔法卡，且该连锁可被无效，且该卡被指定为目标
function c4367330.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 判断对方发动的是魔法卡且该连锁可被无效
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		-- 判断对方发动的魔法卡是否指定此卡为对象
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- 支付1个超量素材作为代价
function c4367330.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理信息为使对方魔法卡发动无效
function c4367330.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家该效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息为使对方魔法卡发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 使对方魔法卡发动无效
function c4367330.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方魔法卡发动无效
	Duel.NegateActivation(ev)
end
