--エクソシスター・ミカエリス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
-- ②：这张卡不会被和从墓地特殊召唤的怪兽的战斗破坏。
-- ③：把这张卡1个超量素材取除才能发动。从卡组把1张「救祓少女」魔法·陷阱卡加入手卡。
function c42741437.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只4星怪兽作为超量素材。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c42741437.effcon)
	e1:SetOperation(c42741437.regop)
	c:RegisterEffect(e1)
	-- 用「救祓少女」怪兽为素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c42741437.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 以对方的场上·墓地1张卡为对象才能发动。那张卡除外。
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
-- 检测该卡是否为超量召唤成功，并且素材检查已标记包含「救祓少女」怪兽（label==1）。
function c42741437.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 在该卡满足条件时注册一个标记（42741437），持续到结束阶段，用于记录本回合曾用「救祓少女」怪兽为素材超量召唤成功。
function c42741437.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(42741437,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查超量素材中是否存在「救祓少女」系列怪兽，并将判断结果存入 e1 的 label，供①效果条件使用。
function c42741437.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x172) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ①效果的发动条件：该卡拥有本回合曾用「救祓少女」素材超量召唤的标记，且①效果在此卡名每回合只能发动一次（由次数限制实现）。
function c42741437.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(42741437)~=0
end
-- ①效果的目标选择：从对方场上或墓地选择1张可以除外的卡作为对象；选择时提示玩家，优先选择场上卡，并设置除外操作信息。
function c42741437.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 效果发动合法性检查：确认对方场上或墓地存在至少1张可以除外的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标：优先从对方场上选择可除外的卡，若场上不足则从墓地选择，最终选择1张作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	-- 将本次连锁的操作信息设置为“除外”，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理时，取得对象卡并确认其仍与该效果相关，然后将其除外。
function c42741437.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第一个（唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将以表侧表示将该对象卡除外，原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 战斗破坏抗性判定：当战斗对象是从墓地特殊召唤的怪兽时，该卡不会被战斗破坏。
function c42741437.batfilter(e,c)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
-- ③效果的发动代价：检查并取除这张卡的1个超量素材。
function c42741437.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤：卡片必须是「救祓少女」系列的魔法·陷阱卡，且能够加入手卡。
function c42741437.thfilter(c)
	return c:IsSetCard(0x172) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果发动时确认卡组中存在符合条件的检索目标；此卡名的③效果每回合只能发动一次（由次数限制实现），并设置“加入手卡”的操作信息。
function c42741437.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中是否存在至少1张满足过滤条件的「救祓少女」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c42741437.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡（具体卡片在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「救祓少女」魔法·陷阱卡加入手卡，并让对方确认。
function c42741437.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c42741437.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
