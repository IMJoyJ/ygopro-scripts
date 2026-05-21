--銀嶺の巨神
-- 效果：
-- 地属性3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方的魔法与陷阱卡区域盖放的1张卡才能发动。选择的卡只要这张卡在场上表侧表示存在不能发动。此外，持有超量素材的这张卡战斗破坏对方怪兽的场合，可以选择自己墓地1只地属性怪兽表侧守备表示特殊召唤。
function c91895091.initial_effect(c)
	-- 设定XYZ召唤手续：地属性3星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择对方的魔法与陷阱卡区域盖放的1张卡才能发动。选择的卡只要这张卡在场上表侧表示存在不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91895091,0))  --"发动限制"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c91895091.cost)
	e1:SetTarget(c91895091.target)
	e1:SetOperation(c91895091.operation)
	c:RegisterEffect(e1)
	-- 此外，持有超量素材的这张卡战斗破坏对方怪兽的场合，可以选择自己墓地1只地属性怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91895091,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c91895091.spcon)
	e2:SetTarget(c91895091.sptg)
	e2:SetOperation(c91895091.spop)
	c:RegisterEffect(e2)
end
-- 检查并执行取除1个超量素材的代价
function c91895091.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤对方魔法与陷阱卡区域盖放的卡（不含场地区）
function c91895091.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 选择对方魔法与陷阱卡区域盖放的1张卡作为效果对象
function c91895091.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c91895091.filter(chkc) end
	-- 检查对方魔法与陷阱卡区域是否存在可作为对象的盖放的卡
	if chk==0 then return Duel.IsExistingTarget(c91895091.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择对方魔法与陷阱卡区域盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(91895091,2))  --"请选择魔法与陷阱卡区域盖放的1张卡"
	-- 选择对方魔法与陷阱卡区域盖放的1张卡作为效果对象
	Duel.SelectTarget(tp,c91895091.filter,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 使选择的卡在自身表侧表示存在期间不能发动
function c91895091.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的对方盖放的卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 选择的卡只要这张卡在场上表侧表示存在不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_TARGET)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 检查此卡是否通过战斗破坏了怪兽且持有超量素材，作为效果发动条件
function c91895091.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetOverlayCount()>0
end
-- 过滤自己墓地可以特殊召唤的地属性怪兽
function c91895091.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 选择自己墓地1只地属性怪兽作为特殊召唤的对象
function c91895091.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c91895091.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的地属性怪兽
		and Duel.IsExistingTarget(c91895091.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的地属性怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c91895091.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 将选择的自己墓地的地属性怪兽表侧守备表示特殊召唤
function c91895091.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
