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
-- ①的自定义特殊召唤规则条件：当c为空时视为满足条件；否则要求本卡持有者场上没有怪兽且主怪兽区有空位。
function c32909498.spcon(e,c)
	if c==nil then return true end
	-- 检查本卡控制者场上（主怪兽区）的怪兽数量是否为0，即满足①“自己场上没有怪兽存在”的条件。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查主怪兽区是否有可用空格，确保有格子可以进行特殊召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 定义②检索的过滤器：满足「俱舍怒威族」字段、是怪兽且能够加入手卡的卡片。
function c32909498.thfilter(c)
	return c:IsSetCard(0x189) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②的发动条件判断与操作信息设置：在发动时确认卡组存在符合条件的「俱舍怒威族」怪兽，并预宣告将1张卡从卡组加入手卡。
function c32909498.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动时点（chk==0），检查己方卡组是否存在至少1张满足检索条件的「俱舍怒威族」怪兽，以此作为能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c32909498.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为：从己方卡组将1张卡加入手卡（供检索相关效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：给出选择加入手卡的提示，从卡组中选出1张符合条件的「俱舍怒威族」怪兽，加入手卡并让对方确认。
function c32909498.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组中选出1张满足thfilter条件的卡片（最多1张）。
	local g=Duel.SelectMatchingCard(tp,c32909498.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送去持有者手卡，即加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义③的取对象过滤器：对方场上的表侧表示卡，且可以被玩家以里侧表示除外。
function c32909498.rmfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- ③攻击宣言场合的目标选择：确认对象为对方场上的表侧表示卡且可被里侧除外，然后选择1张对象并设置除外信息。
function c32909498.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c32909498.rmfilter(chkc,tp) end
	-- 若在发动时点（chk==0），确认对方场上有满足条件的表侧表示卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 弹出选择提示，提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1张满足条件的表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置操作信息：将选中的对象卡除外（数量为1，对象为所选卡）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③的效果处理：取得对象卡，如果对象仍与效果关联，则将其里侧表示除外。
function c32909498.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该连锁效果发动时所选择的对象卡（取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以里侧表示除外，原因记为效果。
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- ③中应对对方发动怪兽效果场合的条件：本次连锁的发动者为对手，且发动的效果是怪兽效果。
function c32909498.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- ③应对对方怪兽效果时的目标选择：确认对手发起了怪兽效果，且对方场上有可被里侧除外的表侧卡，然后选择1张对象并设置除外信息。
function c32909498.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c32909498.rmfilter(chkc,tp) end
	-- 若在发动时点（chk==0），确认当前连锁确实是对方发动的怪兽效果，并且对方场上有满足条件的表侧表示卡可以作为对象。
	if chk==0 then return rp==1-tp and Duel.IsExistingTarget(c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 弹出选择提示，提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1张满足条件的表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,c32909498.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置操作信息：将选中的对象卡除外（数量为1，对象为所选卡）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
