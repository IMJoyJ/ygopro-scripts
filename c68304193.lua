--クシャトリラ・ユニコーン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1张「俱舍怒威族」魔法卡加入手卡。
-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合才能发动。把对方的额外卡组确认，选那之内的1只怪兽里侧表示除外。
function c68304193.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68304193,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c68304193.spcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1张「俱舍怒威族」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68304193,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,68304193)
	e2:SetTarget(c68304193.thtg)
	e2:SetOperation(c68304193.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合才能发动。把对方的额外卡组确认，选那之内的1只怪兽里侧表示除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68304193,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1,68304194)
	e3:SetTarget(c68304193.rmtg)
	e3:SetOperation(c68304193.rmop)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合才能发动。把对方的额外卡组确认，选那之内的1只怪兽里侧表示除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(68304193,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,68304194)
	e4:SetCondition(c68304193.rmcon)
	e4:SetTarget(c68304193.rmtg2)
	e4:SetOperation(c68304193.rmop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件判断函数：自己场上没有怪兽存在，且自身有可用的怪兽区域
function c68304193.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤卡组中属于「俱舍怒威族」的魔法卡，且该卡可以加入手牌
function c68304193.thfilter(c)
	return c:IsSetCard(0x189) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果②（检索魔法卡）的发动准备：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function c68304193.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1张满足条件的「俱舍怒威族」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c68304193.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索魔法卡）的效果处理：从卡组选择1张「俱舍怒威族」魔法卡加入手牌并给对方确认
function c68304193.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「俱舍怒威族」魔法卡
	local g=Duel.SelectMatchingCard(tp,c68304193.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤可以被里侧表示除外的卡
function c68304193.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 效果③（攻击宣言时触发）的发动准备：检查对方额外卡组是否存在可除外的卡，并设置除外的操作信息
function c68304193.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方额外卡组是否存在至少1张可以被里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c68304193.rmfilter,tp,0,LOCATION_EXTRA,1,nil,tp) end
	-- 设置连锁的操作信息，表示该效果会从对方额外卡组将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：确认对方额外卡组，选择其中1张卡里侧表示除外，之后洗切对方额外卡组
function c68304193.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 向发动效果的玩家确认对方额外卡组的所有卡片
	Duel.ConfirmCards(tp,g,true)
	-- 向发动效果的玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:FilterSelect(tp,c68304193.rmfilter,1,1,nil,tp)
	if #sg>0 then
		-- 将选择的卡片里侧表示除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
	-- 洗切对方的额外卡组
	Duel.ShuffleExtra(1-tp)
end
-- 效果③（对方发动怪兽效果时触发）的发动条件：对方发动了怪兽的效果
function c68304193.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果③（对方发动怪兽效果时触发）的发动准备：检查是否是对方发动的效果，且对方额外卡组是否存在可除外的卡，并设置除外的操作信息
function c68304193.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查是否是对方发动的效果，且对方额外卡组是否存在至少1张可以被里侧表示除外的卡
	if chk==0 then return rp==1-tp and Duel.IsExistingMatchingCard(c68304193.rmfilter,tp,0,LOCATION_EXTRA,1,nil,tp) end
	-- 设置连锁的操作信息，表示该效果会从对方额外卡组将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
