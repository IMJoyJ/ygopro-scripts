--雷劫龍－サンダー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。
-- ①：1回合1次，怪兽的效果在手卡发动的场合发动。这张卡的攻击力直到回合结束时上升300。
-- ②：这张卡战斗破坏对方怪兽时，从自己墓地把1张卡除外才能发动。从卡组把1只雷族怪兽加入手卡。
-- ③：对方结束阶段，以除外的1张自己的卡为对象才能发动。那张卡回到卡组最上面或者最下面。
function c55591586.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55591586,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c55591586.spcon)
	e1:SetTarget(c55591586.sptg)
	e1:SetOperation(c55591586.spop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，怪兽的效果在手卡发动的场合发动。这张卡的攻击力直到回合结束时上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55591586,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c55591586.atkcon)
	e2:SetOperation(c55591586.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽时，从自己墓地把1张卡除外才能发动。从卡组把1只雷族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55591586,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为这张卡战斗破坏对方怪兽时
	e3:SetCondition(aux.bdocon)
	e3:SetCost(c55591586.cost)
	e3:SetTarget(c55591586.target)
	e3:SetOperation(c55591586.operation)
	c:RegisterEffect(e3)
	-- ③：对方结束阶段，以除外的1张自己的卡为对象才能发动。那张卡回到卡组最上面或者最下面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55591586,3))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(c55591586.tdcon)
	e4:SetTarget(c55591586.tdtg)
	e4:SetOperation(c55591586.tdop)
	c:RegisterEffect(e4)
end
-- 过滤自身特殊召唤所需除外卡片的条件（墓地的光属性或暗属性怪兽，且可以被除外）
function c55591586.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 自身特殊召唤规则的条件判定（检查怪兽区域空位以及墓地是否存在光属性和暗属性怪兽各1只）
function c55591586.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中满足特殊召唤除外条件的所有卡片
	local g=Duel.GetMatchingGroup(c55591586.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查这些卡片中是否包含光属性和暗属性怪兽各1只
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 自身特殊召唤规则的除外目标选择
function c55591586.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中满足特殊召唤除外条件的所有卡片
	local g=Duel.GetMatchingGroup(c55591586.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择光属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特殊召唤规则的执行操作
function c55591586.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选择的怪兽表侧表示除外以进行特殊召唤
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 攻击力上升效果的发动条件判定（怪兽的效果在手卡发动时）
function c55591586.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的效果的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_HAND
end
-- 攻击力上升效果的执行操作
function c55591586.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 战斗破坏对方怪兽时效果的发动代价（从自己墓地把1张卡除外）
function c55591586.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在可以作为代价除外的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地中1张可以作为代价除外的卡片
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤检索卡片的条件（卡组中的雷族怪兽，且可以加入手卡）
function c55591586.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToHand()
end
-- 战斗破坏对方怪兽时效果的目标判定与操作信息注册
function c55591586.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的雷族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55591586.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 战斗破坏对方怪兽时效果的执行操作（从卡组把1只雷族怪兽加入手卡）
function c55591586.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只雷族怪兽
	local g=Duel.SelectMatchingCard(tp,c55591586.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 回到卡组效果的发动条件判定（对方的结束阶段）
function c55591586.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 回到卡组效果的对象选择与操作信息注册
function c55591586.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
	-- 检查是否存在可以回到卡组的除外的自己的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外的1张自己的卡作为效果对象
	local sg=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理的操作信息为“将选择的卡送回卡组”
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end
-- 回到卡组效果的执行操作（将选择的卡回到卡组最上面或者最下面）
function c55591586.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsExtraDeckMonster()
			-- 让玩家选择将卡片回到卡组最上面还是最下面
			or Duel.SelectOption(tp,aux.Stringid(55591586,4),aux.Stringid(55591586,5))==0 then  --"回到卡组最上面/回到卡组最下面"
			-- 将目标卡片送回卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将目标卡片送回卡组最下面
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
