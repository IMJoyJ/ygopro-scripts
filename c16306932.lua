--超天新龍オッドアイズ・レボリューション・ドラゴン
-- 效果：
-- ←12 【灵摆】 12→
-- ①：自己不是龙族怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：以自己墓地1只龙族的融合·同调·超量怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤。
-- 【怪兽效果】
-- 这张卡不能通常召唤。用从手卡的灵摆召唤或者把自己场上的龙族的融合·同调·超量怪兽各1只解放的场合才能特殊召唤。
-- ①：把这张卡从手卡丢弃，支付500基本分才能发动。从卡组把1只8星以下的龙族灵摆怪兽加入手卡。
-- ②：这张卡的攻击力·守备力上升对方基本分一半的数值。
-- ③：1回合1次，把基本分支付一半才能发动。这张卡以外的双方的场上·墓地的卡全部回到持有者卡组。
function c16306932.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- 允许该卡从手牌灵摆召唤时解除苏生限制
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_HAND)
	-- ①：自己不是龙族怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c16306932.psplimit)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只龙族的融合·同调·超量怪兽为对象才能发动。这张卡破坏，那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16306932,0))  --"特殊召唤墓地怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c16306932.sptg)
	e2:SetOperation(c16306932.spop)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。用从手卡的灵摆召唤或者把自己场上的龙族的融合·同调·超量怪兽各1只解放的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤，即不能通常召唤
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
	-- ①：把这张卡从手卡丢弃，支付500基本分才能发动。从卡组把1只8星以下的龙族灵摆怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(c16306932.hspcon)
	e4:SetTarget(c16306932.hsptg)
	e4:SetOperation(c16306932.hspop)
	c:RegisterEffect(e4)
	-- ②：这张卡的攻击力·守备力上升对方基本分一半的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16306932,1))  --"卡组检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_HAND)
	e5:SetCost(c16306932.thcost)
	e5:SetTarget(c16306932.thtg)
	e5:SetOperation(c16306932.thop)
	c:RegisterEffect(e5)
	-- ③：1回合1次，把基本分支付一半才能发动。这张卡以外的双方的场上·墓地的卡全部回到持有者卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(c16306932.atkval)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
	-- 创建一个用于检查龙族融合·同调·超量怪兽类型的检查函数数组
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TODECK)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCost(c16306932.tdcost)
	e8:SetTarget(c16306932.tdtg)
	e8:SetOperation(c16306932.tdop)
	c:RegisterEffect(e8)
end
-- 当目标怪兽不是龙族且为灵摆召唤时，禁止其特殊召唤
c16306932.spchecks=aux.CreateChecks(Card.IsType,{TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ})
-- 筛选满足龙族且为融合·同调·超量怪兽条件的墓地怪兽
function c16306932.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_DRAGON) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 设置灵摆召唤效果的目标选择函数
function c16306932.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否有满足条件的墓地怪兽可被特殊召唤
function c16306932.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16306932.spfilter(chkc,e,tp) end
	-- 判断目标怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c16306932.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c16306932.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行灵摆召唤效果的操作函数
function c16306932.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断自身和目标怪兽是否有效
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断特殊召唤条件是否满足
function c16306932.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的龙族怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsRace,nil,RACE_DRAGON)
	-- 检查是否满足特殊召唤条件
	return g:CheckSubGroupEach(c16306932.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 设置特殊召唤时的解放目标选择函数
function c16306932.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的龙族怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsRace,nil,RACE_DRAGON)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的龙族怪兽组进行解放
	local sg=g:SelectSubGroupEach(tp,c16306932.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c16306932.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽组解放
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置卡组检索效果的费用支付函数
function c16306932.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足卡组检索的费用条件
	if chk==0 then return e:GetHandler():IsDiscardable() and Duel.CheckLPCost(tp,500) end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 支付500基本分作为费用
	Duel.PayLPCost(tp,500)
end
-- 筛选满足龙族灵摆怪兽条件的卡
function c16306932.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(8) and c:IsAbleToHand()
end
-- 设置卡组检索效果的目标选择函数
function c16306932.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16306932.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组检索卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行卡组检索效果的操作函数
function c16306932.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c16306932.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置攻击力上升效果的计算函数
function c16306932.atkval(e,c)
	-- 计算攻击力为对方基本分的一半
	return math.floor(Duel.GetLP(1-e:GetHandlerPlayer())/2)
end
-- 设置回到卡组效果的费用支付函数
function c16306932.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付基本分的一半作为费用
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置回到卡组效果的目标选择函数
function c16306932.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上和墓地可送回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 执行回到卡组效果的操作函数
function c16306932.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上和墓地可送回卡组的卡（排除自身）
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
