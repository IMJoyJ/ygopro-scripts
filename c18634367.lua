--スクリーン・オブ・レッド
-- 效果：
-- 这张卡的控制者在每次自己结束阶段支付1000基本分。不能支付1000基本分的场合这张卡破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，对方怪兽不能攻击宣言。
-- ②：以自己墓地1只1星调整为对象才能发动。这张卡破坏，那只怪兽特殊召唤。这个效果在场上有「红莲魔龙」存在的场合才能发动和处理。
function c18634367.initial_effect(c)
	-- 将「红莲魔龙」的卡号70902743登记进此卡的代码列表，使此卡在规则上被视为记载了该卡名，供后续效果发动与处理时检测场上是否存在「红莲魔龙」。
	aux.AddCodeList(c,70902743)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x28)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己结束阶段支付1000基本分。不能支付1000基本分的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c18634367.mtcon)
	e3:SetOperation(c18634367.mtop)
	c:RegisterEffect(e3)
	-- ②：以自己墓地1只1星调整为对象才能发动。这张卡破坏，那只怪兽特殊召唤。这个效果在场上有「红莲魔龙」存在的场合才能发动和处理。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18634367,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c18634367.spcon)
	e4:SetTarget(c18634367.sptg)
	e4:SetOperation(c18634367.spop)
	c:RegisterEffect(e4)
end
-- 该函数是结束阶段维持效果的发动条件，判断当前回合玩家是否为此卡的控制者，确保只在控制者的每个结束阶段进行维持处理。
function c18634367.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家等于此卡控制者tp，即此卡的控制者正处于自己的结束阶段，满足维持效果触发条件。
	return Duel.GetTurnPlayer()==tp
end
-- 处理结束阶段的维持效果：若控制者能支付1000基本分则支付，否则将此卡破坏。
function c18634367.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡的控制者是否能够支付1000基本分。
	if Duel.CheckLPCost(tp,1000) then
		-- 扣除控制者1000基本分，作为维持代价。
		Duel.PayLPCost(tp,1000)
	else
		-- 控制者无法支付维持代价时，将此卡以代价理由破坏（规则破坏，不进入连锁）。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 过滤函数：用于判断一张卡是否为表侧表示且卡号是70902743（红莲魔龙），供场上有红莲魔龙的条件检测使用。
function c18634367.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- ②效果的发动条件：此卡不在连锁串处理中（避免连锁中发动），且场上存在表侧表示的「红莲魔龙」。
function c18634367.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查双方场上是否存在至少1张满足cfilter的表侧表示的「红莲魔龙」。
		and Duel.IsExistingMatchingCard(c18634367.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 目标筛选函数：选择自己墓地1只1星调整怪兽，且该怪兽能够满足特殊召唤条件（包括苏生限制等）被特殊召唤。
function c18634367.filter(c,e,tp)
	return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动与取对象：连锁选择对象时验证对象合法性；发动时确认此卡可被破坏、自己有可用怪兽区域、墓地存在符合条件的1星调整，然后选择对象并登记破坏与特殊召唤的操作信息。
function c18634367.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18634367.filter(chkc,e,tp) end
	-- 发动时合法性检查：此卡自身可被破坏，并且自己场上有空余的怪兽区域可用。
	if chk==0 then return e:GetHandler():IsDestructable() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足filter的1星调整怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c18634367.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示框，提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从自己墓地选择1张满足filter的1星调整怪兽，并将其设为本连锁的取对象，返回选中卡片组成的组g。
	local g=Duel.SelectTarget(tp,c18634367.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理中会将此卡破坏，数量为1，用于连锁响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果处理中会将对象组g中的怪兽特殊召唤，数量为1，用于连锁响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果实际处理：先再次确认场上尚有表侧「红莲魔龙」，否则不处理；随后取得此卡与对象，若此卡仍与效果关联且被效果破坏成功，且对象也仍与效果关联，则将对象怪兽特殊召唤。
function c18634367.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查：若场上已不存在表侧表示的「红莲魔龙」，则效果不处理，符合“这个效果在场上有「红莲魔龙」存在的场合才能发动和处理”的处理条件。
	if not Duel.IsExistingMatchingCard(c18634367.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	local c=e:GetHandler()
	-- 取得发动时所选择的1只对象怪兽（即墓地的1星调整）。
	local tc=Duel.GetFirstTarget()
	-- 判断此卡仍与效果关联，并且此卡确实被效果破坏，且对象也仍与效果关联时，才继续执行特殊召唤。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将选择的那只1星调整怪兽以表侧表示特殊召唤到tp的场上；仍检查其召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
