--ショット・ガン・シャッフル
-- 效果：
-- 支付300基本分。自己或对方洗1次卡组。这个效果1回合只能使用1次。
function c12183332.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一张永续魔法效果，使其可以在场地区域发动，效果为支付300基本分后选择自己或对方洗牌，且每回合只能发动一次
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12183332,0))  --"洗牌"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c12183332.cost)
	e2:SetTarget(c12183332.target)
	e2:SetOperation(c12183332.operation)
	c:RegisterEffect(e2)
end
-- 支付300基本分的费用处理函数
function c12183332.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付300基本分
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 让玩家支付300基本分
	Duel.PayLPCost(tp,300)
end
-- 效果的目标选择函数，判断自己或对方卡组是否有多于1张牌
function c12183332.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组是否有多于1张牌或对方卡组是否有多于1张牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 end
end
-- 效果的发动处理函数，根据选择决定洗切自己或对方卡组
function c12183332.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt
	-- 判断自己卡组是否有多于1张牌
	local res0=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
	-- 判断对方卡组是否有多于1张牌
	local res1=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1
	if res0 and res1 then
		-- 当自己和对方卡组都有多于1张牌时，让玩家选择洗切自己的卡组
		opt=Duel.SelectOption(tp,aux.Stringid(12183332,1),aux.Stringid(12183332,2))  --"自己洗切卡组" / "对方洗切卡组"
	elseif res0 then
		-- 当只有自己卡组有多于1张牌时，让玩家选择洗切自己的卡组
		opt=Duel.SelectOption(tp,aux.Stringid(12183332,1))  --"自己洗切卡组"
	elseif res1 then
		-- 当只有对方卡组有多于1张牌时，让玩家选择洗切对方的卡组
		opt=Duel.SelectOption(tp,aux.Stringid(12183332,2))+1  --"对方洗切卡组"
	else
		return
	end
	if opt==0 then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
	else
		-- 洗切对方的卡组
		Duel.ShuffleDeck(1-tp)
	end
end
