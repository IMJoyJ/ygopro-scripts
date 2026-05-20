--DDD怒涛大王エグゼクティブ・シーザー
-- 效果：
-- 恶魔族6星怪兽×2
-- ①：包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以让这张卡和自己场上1只「DD」怪兽的攻击力直到回合结束时上升1800。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
function c79559912.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤手续：恶魔族6星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),6,2)
	-- ①：包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以让这张卡和自己场上1只「DD」怪兽的攻击力直到回合结束时上升1800。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(79559912,0))  --"发动无效并破坏"
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c79559912.discon)
	e1:SetCost(c79559912.discost)
	e1:SetTarget(c79559912.distg)
	e1:SetOperation(c79559912.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79559912,2))  --"卡组「契约书」卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c79559912.thcon)
	e2:SetTarget(c79559912.thtg)
	e2:SetOperation(c79559912.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：检查连锁中的效果是否包含特殊召唤效果，且该发动可以被无效
function c79559912.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 自身处于战斗破坏确定状态，或者该连锁的发动无法被无效时，不能发动
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
-- 效果①的消耗：取除这张卡的1个超量素材
function c79559912.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的靶向：确认为无效发动并破坏的操作
function c79559912.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤条件：自己场上表侧表示的「DD」怪兽
function c79559912.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 效果①的处理：使发动无效并破坏，之后可选择让这张卡和自己场上1只「DD」怪兽的攻击力直到回合结束时上升1800
function c79559912.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 成功使该发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 成功破坏该卡，且自身在场上表侧表示存在
		and Duel.Destroy(eg,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsFaceup()
		-- 检查自己场上是否存在除自身以外的表侧表示「DD」怪兽
		and Duel.IsExistingMatchingCard(c79559912.atkfilter,tp,LOCATION_MZONE,0,1,c)
		-- 询问玩家是否选择让攻击力上升
		and Duel.SelectYesNo(tp,aux.Stringid(79559912,1)) then  --"是否选怪兽上升攻击力？"
		-- 中断当前效果处理，使后续的攻击力上升处理与破坏不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家选择自己场上1只除自身以外的表侧表示「DD」怪兽
		local g=Duel.SelectMatchingCard(tp,c79559912.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
		local tc=g:GetFirst()
		-- 选中该怪兽并向双方玩家展示
		Duel.HintSelection(g)
		-- 让这张卡和自己场上1只「DD」怪兽的攻击力直到回合结束时上升1800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
-- 效果②的发动条件：这张卡从场上送去墓地
function c79559912.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中可以加入手牌的「契约书」卡
function c79559912.thfilter(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end
-- 效果②的靶向：确认从卡组检索「契约书」卡的操作
function c79559912.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「契约书」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79559912.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组把1张「契约书」卡加入手卡
function c79559912.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「契约书」卡
	local g=Duel.SelectMatchingCard(tp,c79559912.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
