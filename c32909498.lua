--クシャトリラ・フェンリル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1只「俱舍怒威族」怪兽加入手卡。
-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡里侧表示除外。
function c32909498.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32909498,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32909498.spcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1只「俱舍怒威族」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32909498,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32909498)
	e2:SetTarget(c32909498.thtg)
	e2:SetOperation(c32909498.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡里侧表示除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32909498,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1,32909499)
	e3:SetTarget(c32909498.rmtg)
	e3:SetOperation(c32909498.rmop)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡里侧表示除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(32909498,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,32909499)
	e4:SetCondition(c32909498.rmcon)
	e4:SetTarget(c32909498.rmtg2)
	e4:SetOperation(c32909498.rmop)
	c:RegisterEffect(e4)
end
-- 检查是否满足特殊召唤条件：自己场上没有怪兽且有可用怪兽区域
function c32909498.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检索过滤函数：满足「俱舍怒威族」且为怪兽且可加入手牌
function c32909498.thfilter(c)
	return c:IsSetCard(0x189) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息：从卡组检索1张「俱舍怒威族」怪兽加入手牌
function c32909498.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组存在满足条件的「俱舍怒威族」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32909498.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息：从卡组检索1张「俱舍怒威族」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果：选择并加入手牌
function c32909498.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c32909498.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 除外效果的过滤函数：表侧表示且可除外
function c32909498.rmfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 设置攻击宣言时的除外效果处理信息：选择对方场上1张表侧表示的卡除外
function c32909498.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c32909498.rmfilter(chkc,tp) end
	-- 判断是否满足攻击宣言时除外效果的条件：对方场上存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张表侧表示的卡除外
	local g=Duel.SelectTarget(tp,c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置攻击宣言时的除外效果处理信息：选择对方场上1张表侧表示的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行攻击宣言时的除外效果：将选中的卡除外
function c32909498.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 对方怪兽效果发动时除外效果的触发条件：对方发动怪兽效果
function c32909498.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 设置对方怪兽效果发动时的除外效果处理信息：选择对方场上1张表侧表示的卡除外
function c32909498.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c32909498.rmfilter(chkc,tp) end
	-- 判断是否满足对方怪兽效果发动时除外效果的条件：对方发动怪兽效果且对方场上存在满足条件的卡
	if chk==0 then return rp==1-tp and Duel.IsExistingTarget(c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张表侧表示的卡除外
	local g=Duel.SelectTarget(tp,c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置对方怪兽效果发动时的除外效果处理信息：选择对方场上1张表侧表示的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
