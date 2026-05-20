--エクソシスター・カスピテル
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。这个回合，双方不能从墓地把怪兽特殊召唤。
-- ②：这张卡不会被和从墓地特殊召唤的怪兽的战斗破坏。
-- ③：把这张卡1个超量素材取除才能发动。从卡组把1只「救祓少女」怪兽加入手卡。
function c78135071.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。这个回合，双方不能从墓地把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78135071,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,78135071)
	e1:SetCondition(c78135071.con)
	e1:SetOperation(c78135071.op)
	c:RegisterEffect(e1)
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c78135071.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除才能发动。从卡组把1只「救祓少女」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78135071,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,78135072)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c78135071.thcost)
	e3:SetTarget(c78135071.thtg)
	e3:SetOperation(c78135071.thop)
	c:RegisterEffect(e3)
	-- ②：这张卡不会被和从墓地特殊召唤的怪兽的战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(c78135071.batfilter)
	c:RegisterEffect(e4)
end
-- 检查超量素材中是否存在「救祓少女」怪兽，并为效果1设置对应的Label标记
function c78135071.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x172) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 效果1的发动条件：这张卡是超量召唤成功，且超量素材中存在「救祓少女」怪兽
function c78135071.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 效果1的效果处理：注册一个全局效果，使双方在这个回合不能从墓地把怪兽特殊召唤
function c78135071.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，双方不能从墓地把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c78135071.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果（使限制特殊召唤的效果生效）
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：限制从墓地特殊召唤怪兽
function c78135071.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 战斗破坏免疫的过滤条件：对方怪兽的特殊召唤位置为墓地
function c78135071.batfilter(e,c)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
-- 效果3的代价：取除这张卡的1个超量素材
function c78135071.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤条件：卡组中的「救祓少女」怪兽
function c78135071.thfilter(c)
	return c:IsSetCard(0x172) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 效果3的发动准备：检查卡组中是否存在可检索的「救祓少女」怪兽，并设置检索的操作信息
function c78135071.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「救祓少女」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78135071.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果3的效果处理：从卡组选择1只「救祓少女」怪兽加入手卡，并给对方确认
function c78135071.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「救祓少女」怪兽
	local g=Duel.SelectMatchingCard(tp,c78135071.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
