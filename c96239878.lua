--束ねられし力
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己作使用「青眼白龙」或者「黑魔术师」的仪式·融合召唤成功的场合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1只7星以上的通常怪兽为对象才能发动。那只怪兽加入手卡或回到卡组。
function c96239878.initial_effect(c)
	-- 注册该卡记有「青眼白龙」和「黑魔术师」的卡名
	aux.AddCodeList(c,89631139,46986414)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己作使用「青眼白龙」或者「黑魔术师」的仪式·融合召唤成功的场合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96239878,0))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,96239878)
	e2:SetCondition(c96239878.rmcon)
	e2:SetTarget(c96239878.rmtg)
	e2:SetOperation(c96239878.rmop)
	c:RegisterEffect(e2)
	-- ①：自己作使用「青眼白龙」或者「黑魔术师」的仪式·融合召唤成功的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c96239878.valcheck)
	c:RegisterEffect(e4)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1只7星以上的通常怪兽为对象才能发动。那只怪兽加入手卡或回到卡组。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(96239878,1))  --"回收墓地"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,96239879)
	e5:SetCost(c96239878.thcost)
	e5:SetTarget(c96239878.thtg)
	e5:SetOperation(c96239878.thop)
	c:RegisterEffect(e5)
end
-- 过滤卡名是「青眼白龙」或「黑魔术师」的卡片（用于仪式召唤素材检测）
function c96239878.mtfilter1(c)
	return c:IsCode(89631139,46986414)
end
-- 过滤融合素材名是「青眼白龙」或「黑魔术师」的卡片（用于融合召唤素材检测）
function c96239878.mtfilter2(c)
	return c:IsFusionCode(89631139,46986414)
end
-- 检查召唤素材，若使用了「青眼白龙」或「黑魔术师」，则给召唤出的怪兽注册对应的Flag标记
function c96239878.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(c96239878.mtfilter1,1,nil) then
		c:RegisterFlagEffect(96239878,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	end
	if g:IsExists(c96239878.mtfilter2,1,nil) then
		c:RegisterFlagEffect(96239879,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判定是否为自己将使用「青眼白龙」或「黑魔术师」作为素材的仪式·融合怪兽召唤成功的场合
function c96239878.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonPlayer(tp)
		and (tc:IsSummonType(SUMMON_TYPE_RITUAL) and tc:GetFlagEffect(96239878)~=0
			or tc:IsSummonType(SUMMON_TYPE_FUSION) and tc:GetFlagEffect(96239879)~=0)
end
-- 效果①的靶向目标选择：以对方场上或墓地的一张卡为对象
function c96239878.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (chkc:IsOnField() or chkc:IsLocation(LOCATION_GRAVE)) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上或墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从对方场上（若无则从墓地）选择1张可除外的卡作为效果对象
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置连锁处理中的操作信息：除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的处理：将作为对象的卡除外
function c96239878.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动代价：将魔法与陷阱区域表侧表示的这张卡送去墓地
function c96239878.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中7星以上的通常怪兽，且该怪兽能加入手卡或回到卡组
function c96239878.thfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
-- 效果②的靶向目标选择：以自己墓地1只7星以上的通常怪兽为对象
function c96239878.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c96239878.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的7星以上通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c96239878.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96239878.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理中的操作信息：将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁处理中的操作信息：将选中的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理：将作为对象的怪兽加入手卡或回到卡组
function c96239878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 判定是否只能回到卡组，或者在两者皆可时由玩家选择“回到卡组”选项
		if tc:IsAbleToDeck() and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,aux.Stringid(96239878,2))==1) then  --"回到卡组"
			-- 将目标怪兽回到卡组并洗牌
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		else
			-- 将目标怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
