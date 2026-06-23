--オッドアイズ・セイバー・ドラゴン
-- 效果：
-- ①：这张卡在手卡的场合，把自己场上1只光属性怪兽解放才能发动。从手卡·卡组以及自己场上的表侧表示怪兽之中选1只「异色眼龙」送去墓地，这张卡特殊召唤。
-- ②：这张卡战斗破坏怪兽送去墓地时才能发动。选对方场上1只怪兽破坏。
function c19221310.initial_effect(c)
	-- ①：这张卡在手卡的场合，把自己场上1只光属性怪兽解放才能发动。从手卡·卡组以及自己场上的表侧表示怪兽之中选1只「异色眼龙」送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19221310,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c19221310.spcost)
	e1:SetTarget(c19221310.sptg)
	e1:SetOperation(c19221310.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地时才能发动。选对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19221310,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测本次战斗是否与该卡有关，用于判断是否满足效果发动条件
	e2:SetCondition(aux.bdgcon)
	e2:SetTarget(c19221310.destg)
	e2:SetOperation(c19221310.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的光属性怪兽，可以作为解放对象
function c19221310.cfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查场上是否存在满足条件的「异色眼龙」，用于确认是否可以发动效果
		and Duel.IsExistingMatchingCard(c19221310.filter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK,0,1,c)
end
-- 效果发动时的费用处理，检查并选择1只符合条件的光属性怪兽进行解放
function c19221310.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足发动条件，即是否可以解放符合条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19221310.cfilter,1,nil,ft,tp) end
	-- 选择1只符合条件的光属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c19221310.cfilter,1,1,nil,ft,tp)
	-- 执行解放操作，将选中的怪兽从场上解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于选择可以送去墓地的「异色眼龙」
function c19221310.filter(c)
	return c:IsCode(53025096) and c:IsAbleToGrave()
		and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
end
-- 设置效果发动时的操作信息，包括送去墓地和特殊召唤的目标
function c19221310.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要处理的送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息，表示将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，选择并送去墓地1只「异色眼龙」，然后特殊召唤自身
function c19221310.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张满足条件的「异色眼龙」送去墓地
	local g=Duel.SelectMatchingCard(tp,c19221310.filter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否成功将卡送去墓地并确认自身是否还在场上
	if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置效果发动时的操作信息，表示将要破坏对方怪兽
function c19221310.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽可以被破坏
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽作为可破坏对象
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表示将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，选择并破坏对方1只怪兽
function c19221310.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只对方场上的怪兽进行破坏
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为破坏对象的怪兽动画
		Duel.HintSelection(g)
		-- 执行破坏操作，将选中的怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
