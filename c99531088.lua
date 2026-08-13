--ジュラシック・パワー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的恐龙族怪兽的攻击力上升300。
-- ②：自己在5星以上的恐龙族怪兽召唤的场合需要的解放可以不用。
-- ③：从自己的手卡·场上（表侧表示）把1只恐龙族怪兽送去墓地才能发动。从卡组把1只守备力1200的恐龙族怪兽加入手卡。
local s,id,o=GetID()
-- 初始化并注册本卡所有效果：e1为永续魔法/陷阱的发动许可效果；e2为①提升自己恐龙族攻击力；e3为②提供5星以上恐龙族无解放召唤的规则效果；e4为③检索守备力1200恐龙族的起动效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的恐龙族怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定攻击力上升效果只对自己场上表侧表示的恐龙族怪兽适用。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ②：自己在5星以上的恐龙族怪兽召唤的场合需要的解放可以不用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"使用「侏罗纪力量」的效果不用解放召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCondition(s.ntcon)
	e3:SetTarget(s.nttg)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：从自己的手卡·场上（表侧表示）把1只恐龙族怪兽送去墓地才能发动。从卡组把1只守备力1200的恐龙族怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 无解放召唤规则效果的发动条件：没有指定具体怪兽时直接允许该召唤方式存在；指定怪兽时要求该召唤需要解放数为0且自己主要怪兽区有空位。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 具体条件为：本次召唤无需解放，并且召唤玩家场上有可用的主要怪兽区域。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 可适用无解放召唤的怪兽必须满足：等级在5星以上且为恐龙族。
function s.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DINOSAUR)
end
-- ③效果发动代价的过滤条件：恐龙族、可以作为代价送去墓地、且位于手牌或场上表侧表示。
function s.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToGraveAsCost() and c:IsFaceupEx()
end
-- ③效果的代价处理：从自己手卡或场上表侧表示选择1只恐龙族怪兽送去墓地作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认是否存在至少1只满足条件的恐龙族怪兽可供送去墓地，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示其选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家从自己的手卡或场上表侧表示中选择1只满足条件的恐龙族怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的恐龙族怪兽送去墓地，处理原因为代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索目标的过滤条件：恐龙族、守备力为1200、且可以加入手卡。
function s.filter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsDefense(1200) and c:IsAbleToHand()
end
-- ③效果的发动目标阶段：检查卡组是否存在符合条件的恐龙族，并设置本次连锁的操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：若卡组中没有守备力1200的恐龙族怪兽，则③效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：效果处理时将1张卡从卡组加入手卡，用于连锁响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只守备力1200的恐龙族怪兽加入手卡，并向对手展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足filter条件的恐龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认，以告知检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
