--エクソシスター・ミカエリス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
-- ②：这张卡不会被和从墓地特殊召唤的怪兽的战斗破坏。
-- ③：把这张卡1个超量素材取除才能发动。从卡组把1张「救祓少女」魔法·陷阱卡加入手卡。
function c42741437.initial_effect(c)
	-- 添加超量召唤手续，使用等级为4、数量为2的怪兽进行超量召唤
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c42741437.effcon)
	e1:SetOperation(c42741437.regop)
	c:RegisterEffect(e1)
	-- 检查超量素材中是否包含「救祓少女」卡，若包含则标记效果可用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c42741437.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42741437,0))  --"对方卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,42741437)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c42741437.rmcon)
	e3:SetTarget(c42741437.rmtg)
	e3:SetOperation(c42741437.rmop)
	c:RegisterEffect(e3)
	-- ②：这张卡不会被和从墓地特殊召唤的怪兽的战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(c42741437.batfilter)
	c:RegisterEffect(e4)
	-- ③：把这张卡1个超量素材取除才能发动。从卡组把1张「救祓少女」魔法·陷阱卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42741437,1))  --"卡组检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1,42741438)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(c42741437.thcost)
	e5:SetTarget(c42741437.thtg)
	e5:SetOperation(c42741437.thop)
	c:RegisterEffect(e5)
end
-- 判断是否为超量召唤且标记为可用状态
function c42741437.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 为该卡注册一个标志效果，用于记录是否已使用过①效果
function c42741437.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(42741437,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查超量召唤时使用的素材是否包含「救祓少女」卡组，若包含则设置标记为1
function c42741437.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x172) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否已使用过①效果
function c42741437.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(42741437)~=0
end
-- 设置目标选择条件，允许选择对方场上或墓地的卡作为除外对象
function c42741437.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择目标卡，若无足够场上卡则使用普通选择方式
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作，将目标卡除外
function c42741437.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以除外形式移除
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断攻击怪兽是否为从墓地特殊召唤的怪兽
function c42741437.batfilter(e,c)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
-- 消耗1个超量素材作为发动③效果的费用
function c42741437.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，筛选「救祓少女」魔法·陷阱卡
function c42741437.thfilter(c)
	return c:IsSetCard(0x172) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置检索卡组中「救祓少女」魔法·陷阱卡的操作信息
function c42741437.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42741437.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，记录将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，从卡组选择1张「救祓少女」魔法·陷阱卡加入手牌
function c42741437.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c42741437.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
