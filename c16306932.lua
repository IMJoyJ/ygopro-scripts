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
	-- 为这张卡附加灵摆怪兽属性，使其可以作为灵摆卡放置在灵摆区，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 使这张卡从手卡进行灵摆召唤时也视为正规出场程序，解除苏生限制，从而可以用灵摆召唤将这张卡从手卡特殊召唤。
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
	-- 将该卡的特殊召唤条件判定设为恒为false，使这张卡不能通过其他效果或规则被随意特殊召唤，只能依靠本卡自带的特殊召唤手续。
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
	-- 用从手卡的灵摆召唤或者把自己场上的龙族的融合·同调·超量怪兽各1只解放的场合才能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(c16306932.hspcon)
	e4:SetTarget(c16306932.hsptg)
	e4:SetOperation(c16306932.hspop)
	c:RegisterEffect(e4)
	-- ①：把这张卡从手卡丢弃，支付500基本分才能发动。从卡组把1只8星以下的龙族灵摆怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16306932,1))  --"卡组检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_HAND)
	e5:SetCost(c16306932.thcost)
	e5:SetTarget(c16306932.thtg)
	e5:SetOperation(c16306932.thop)
	c:RegisterEffect(e5)
	-- ②：这张卡的攻击力·守备力上升对方基本分一半的数值。
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
	-- ③：1回合1次，把基本分支付一半才能发动。这张卡以外的双方的场上·墓地的卡全部回到持有者卡组。
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
-- 生成三个类型判定闭包，分别检测融合、同调、超量，供“各1只解放”时逐一选择对应种类。
c16306932.spchecks=aux.CreateChecks(Card.IsType,{TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ})
-- 灵摆召唤限制的判定：若被灵摆召唤的怪兽不是龙族则不允许该灵摆召唤，即“自己不是龙族怪兽不能灵摆召唤”。
function c16306932.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_DRAGON) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判定墓地怪兽是否满足可特殊召唤条件：必须是龙族，且是融合·同调·超量怪兽之一，且能通过此效果特殊召唤。
function c16306932.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检查：指定自己墓地1只满足条件的龙族融合·同调·超量怪兽作为对象；同时检查自己怪兽区是否有空位。
function c16306932.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16306932.spfilter(chkc,e,tp) end
	-- 检查自己主怪兽区是否有可用空格，用于容纳后续特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足过滤条件的龙族融合·同调·超量怪兽作为效果对象。
		and Duel.IsExistingTarget(c16306932.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 以弹窗形式提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的怪兽作为效果对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c16306932.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：预定要将这张卡自身破坏（用于让其他卡能连锁对应）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 登记操作信息：预定要将选择的目标怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若这张卡仍与效果关联且被效果破坏成功，且目标怪兽仍与效果关联，则将目标怪兽特殊召唤。
function c16306932.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得该连锁登记的对象卡（即选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判定：这张卡自身仍与效果关联，且成功被效果破坏，且目标怪兽仍与效果关联，条件满足才继续处理。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 特殊召唤手续的条件检查：当c为nil时直接返回true用于系统查询；否则从可用解放的怪兽中确认能凑齐龙族融合·同调·超量各1只，且解放后主怪兽区仍有空位。
function c16306932.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家可以解放的怪兽组，并筛选出其中的龙族怪兽，作为解放候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsRace,nil,RACE_DRAGON)
	-- 检查候选龙族怪兽中是否能选出融合·同调·超量各1只作为解放，并且解放后仍有足够的怪兽区空格（aux.mzctcheckrel同时验证可解放性）。
	return g:CheckSubGroupEach(c16306932.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 特殊召唤手续的目标选择：让玩家从可解放的龙族怪兽中选择融合·同调·超量各1只，选定后保存并允许发动。
function c16306932.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可以解放的怪兽组，并筛选出其中的龙族怪兽，作为解放候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsRace,nil,RACE_DRAGON)
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从候选龙族怪兽中，要求玩家选择融合·同调·超量各1只，并确认解放后格子足够，成功则返回所选的解放组。
	local sg=g:SelectSubGroupEach(tp,c16306932.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的实际执行：将之前保存的解放组怪兽解放，完成特殊召唤的代价。
function c16306932.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽作为特殊召唤手续的代价解放。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 怪兽效果①的代价处理：检查并执行丢弃手卡的这张卡并支付500LP。
function c16306932.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价是否可行：这张卡在手卡且能被丢弃，且玩家能支付500LP。
	if chk==0 then return e:GetHandler():IsDiscardable() and Duel.CheckLPCost(tp,500) end
	-- 将这张卡从手卡丢弃送去墓地（作为发动代价）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 定义检索条件：8星以下的龙族灵摆怪兽，且能够加入手卡。
function c16306932.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(8) and c:IsAbleToHand()
end
-- 发动条件与处理信息：卡组存在满足条件的龙族灵摆怪兽时才能发动，并登记检索入手卡的操作信息。
function c16306932.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的龙族灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c16306932.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果预定从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张满足条件的龙族灵摆怪兽加入手卡，并让对方确认。
function c16306932.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张符合条件的龙族灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c16306932.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 计算攻击力上升数值：对方基本分的一半（向下取整）。
function c16306932.atkval(e,c)
	-- 返回对方当前LP的一半向下取整，作为攻击力/守备力的上升量。
	return math.floor(Duel.GetLP(1-e:GetHandlerPlayer())/2)
end
-- 效果③的代价：支付当前LP的一半（向下取整）作为发动代价。
function c16306932.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付玩家当前LP的一半（向下取整）LP作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 效果③的目标检查与信息登记：获取双方场上·墓地里除了这张卡以外的所有可回卡组的卡，并登记送回卡组的操作信息。
function c16306932.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上·墓地中除这张卡自身以外的所有能够回到卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 登记操作信息：预定将上述所有卡送回持有者卡组，数量为获取到的卡组数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将双方场上·墓地里除了这张卡以外的所有可回卡组的卡全部送回持有者卡组，并洗牌。
function c16306932.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取双方场上·墓地中除这张卡（且与效果仍有关联）以外的所有可回卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将这些卡送回持有者卡组，并标记为需要洗切（即回到卡组并进行洗牌）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
