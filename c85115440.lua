--十二獣ブルホーン
-- 效果：
-- 4星怪兽×2
-- 「十二兽 牛犄」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只可以通常召唤的兽战士族怪兽加入手卡。
function c85115440.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2,c85115440.ovfilter,aux.Stringid(85115440,0),2,c85115440.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c85115440.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c85115440.defval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只可以通常召唤的兽战士族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85115440,1))  --"兽战士族怪兽加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c85115440.cost)
	e3:SetTarget(c85115440.target)
	e3:SetOperation(c85115440.operation)
	c:RegisterEffect(e3)
end
-- 过滤用于重叠超量召唤的怪兽：自己场上表侧表示的「十二兽」怪兽（同名卡除外）
function c85115440.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(85115440)
end
-- 重叠超量召唤时的额外操作：检查并注册每回合1次重叠超量召唤的玩家标识
function c85115440.xyzop(e,tp,chk)
	-- 检查当前回合该玩家是否已经进行过「十二兽 牛犄」的重叠超量召唤
	if chk==0 then return Duel.GetFlagEffect(tp,85115440)==0 end
	-- 给玩家注册本回合已进行过重叠超量召唤的标识（持续到回合结束）
	Duel.RegisterFlagEffect(tp,85115440,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤作为超量素材的「十二兽」怪兽（且攻击力大于等于0）
function c85115440.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算作为超量素材的「十二兽」怪兽的攻击力总和
function c85115440.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c85115440.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 过滤作为超量素材的「十二兽」怪兽（且守备力大于等于0）
function c85115440.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算作为超量素材的「十二兽」怪兽的守备力总和
function c85115440.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c85115440.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 效果发动代价：取除这张卡的1个超量素材
function c85115440.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中可以通常召唤且能加入手牌的兽战士族怪兽
function c85115440.filter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsSummonableCard() and c:IsAbleToHand()
end
-- 效果发动目标：检查卡组中是否存在符合条件的怪兽，并向对方玩家提示，设置检索的操作信息
function c85115440.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以通常召唤并加入手牌的兽战士族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85115440.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示当前发动的效果（“兽战士族怪兽加入手卡”）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的兽战士族怪兽加入手牌，并给对方确认
function c85115440.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只符合条件的兽战士族怪兽
	local g=Duel.SelectMatchingCard(tp,c85115440.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
