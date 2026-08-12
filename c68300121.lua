--魔鍵憑霊－ウェパルトゥ
-- 效果：
-- 4星怪兽×2
-- ①：这张卡超量召唤成功的场合，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只4星以上的通常怪兽加入手卡。
-- ②：这张卡有通常怪兽在作为超量素材的场合，得到以下效果。
-- ●持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方怪兽和这张卡进行战斗的伤害步骤开始时，把这张卡1个超量素材取除才能发动。对方必须把那只怪兽送去墓地。
function c68300121.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的场合，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只4星以上的通常怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68300121,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(c68300121.thcost)
	e1:SetCondition(c68300121.thcon)
	e1:SetTarget(c68300121.thtg)
	e1:SetOperation(c68300121.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡有通常怪兽在作为超量素材的场合，得到以下效果。●持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方怪兽和这张卡进行战斗的伤害步骤开始时，把这张卡1个超量素材取除才能发动。对方必须把那只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68300121,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c68300121.rmcon)
	e2:SetCost(c68300121.rmcost)
	e2:SetTarget(c68300121.rmtg)
	e2:SetOperation(c68300121.rmop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：此卡超量召唤成功
function c68300121.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的代价：取除此卡的1个超量素材
function c68300121.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的过滤条件：4星以上的通常怪兽且能加入手卡
function c68300121.thfilter(c)
	return c:IsLevelAbove(4) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 效果①的靶向/发动准备：检查卡组或墓地是否存在符合条件的卡，并设置检索/回收的操作信息
function c68300121.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1只满足条件的4星以上通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68300121.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的处理：从卡组或墓地选1只符合条件的怪兽加入手卡（受王家之谷影响）
function c68300121.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地选择1只满足条件的怪兽（适用王家之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c68300121.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 属性匹配过滤条件：墓地中与战斗对手属性相同，且为通常怪兽或「魔键」怪兽
function c68300121.attrchkfilter(c,attr)
	return c:IsAttribute(attr) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
end
-- 效果②的发动条件：有通常怪兽作为超量素材，且对方战斗怪兽的属性与自己墓地的通常怪兽或「魔键」怪兽相同
function c68300121.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc~=nil and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_NORMAL)
		-- 检查自己墓地是否存在与对方战斗怪兽属性相同的通常怪兽或「魔键」怪兽
		and Duel.IsExistingMatchingCard(c68300121.attrchkfilter,tp,LOCATION_GRAVE,0,1,nil,tc:GetAttribute())
end
-- 效果②的代价：取除此卡的1个超量素材
function c68300121.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的靶向/发动准备：设置将对方战斗怪兽送去墓地的操作信息
function c68300121.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方的战斗怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetLabelObject(),1,0,0)
end
-- 效果②的处理：使对方必须将进行战斗的那只怪兽送去墓地
function c68300121.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 对方玩家因规则（玩家受到的效果）将该怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_RULE,1-tp)
	end
end
