--スクリーン・オブ・レッド
-- 效果：
-- 这张卡的控制者在每次自己结束阶段支付1000基本分。不能支付1000基本分的场合这张卡破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，对方怪兽不能攻击宣言。
-- ②：以自己墓地1只1星调整为对象才能发动。这张卡破坏，那只怪兽特殊召唤。这个效果在场上有「红莲魔龙」存在的场合才能发动和处理。
function c18634367.initial_effect(c)
	-- 记录此卡具有「红莲魔龙」的卡名代码
	aux.AddCodeList(c,70902743)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x28)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，对方怪兽不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己结束阶段支付1000基本分。不能支付1000基本分的场合这张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c18634367.mtcon)
	e3:SetOperation(c18634367.mtop)
	c:RegisterEffect(e3)
	-- 以自己墓地1只1星调整为对象才能发动。这张卡破坏，那只怪兽特殊召唤。这个效果在场上有「红莲魔龙」存在的场合才能发动和处理
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
-- 判断是否为当前回合玩家
function c18634367.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 处理结束阶段的LP支付或破坏效果
function c18634367.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否能支付1000基本分
	if Duel.CheckLPCost(tp,1000) then
		-- 让当前玩家支付1000基本分
		Duel.PayLPCost(tp,1000)
	else
		-- 若无法支付则破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 过滤函数，用于判断场上是否存在「红莲魔龙」
function c18634367.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 判断此效果是否可以发动
function c18634367.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 判断场上有「红莲魔龙」存在
		and Duel.IsExistingMatchingCard(c18634367.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤函数，用于筛选墓地中的1星调整
function c18634367.filter(c,e,tp)
	return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理条件
function c18634367.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18634367.filter(chkc,e,tp) end
	-- 检查此卡是否可被破坏
	if chk==0 then return e:GetHandler():IsDestructable() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合条件的1星调整
		and Duel.IsExistingTarget(c18634367.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的1星调整
	local g=Duel.SelectTarget(tp,c18634367.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将此卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c18634367.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有「红莲魔龙」存在
	if not Duel.IsExistingMatchingCard(c18634367.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认此卡与目标怪兽均有效
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
