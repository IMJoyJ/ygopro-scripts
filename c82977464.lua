--S－Force スペシメン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：对方场上有怪兽存在的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「治安战警队」怪兽为对象才能发动。那只怪兽在对方怪兽的正对面的自己场上特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「治安战警队」怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
function c82977464.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「治安战警队」怪兽为对象才能发动。那只怪兽在对方怪兽的正对面的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82977464,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,82977464)
	e1:SetCondition(c82977464.spcon)
	e1:SetTarget(c82977464.sptg)
	e1:SetOperation(c82977464.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「治安战警队」怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82977464,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,82977464)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c82977464.mvtg)
	e2:SetOperation(c82977464.mvop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c82977464.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方场上是否有怪兽存在
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤自己墓地或除外状态的「治安战警队」怪兽且能特殊召唤的卡片
function c82977464.spfilter(c,e,tp,zone)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x156) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动准备与目标选择函数
function c82977464.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=0
	-- 获取对方场上的怪兽卡组
	local lg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 遍历对方场上的怪兽
	for lc in aux.Next(lg) do
		zone=bit.bor(zone,lc:GetColumnZone(LOCATION_MZONE,tp))
	end
	zone=zone&0x1f
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c82977464.spfilter(chkc,e,tp,zone) end
	-- 在发动步骤0时，判定自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地或除外区是否存在符合特殊召唤条件的「治安战警队」怪兽
		and Duel.IsExistingTarget(c82977464.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外区1只符合条件的「治安战警队」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c82977464.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,zone)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的执行函数
function c82977464.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local zone=0
	-- 获取对方场上的怪兽卡组
	local lg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 遍历对方场上的怪兽以确定其正对面的区域
	for lc in aux.Next(lg) do
		zone=bit.bor(zone,lc:GetColumnZone(LOCATION_MZONE,tp))
	end
	zone=zone&0x1f
	if zone~=0 then
		-- 将目标怪兽在对方怪兽正对面的自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 过滤自己场上表侧表示的「治安战警队」怪兽
function c82977464.mvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156)
end
-- 效果②的发动准备与目标选择函数
function c82977464.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82977464.mvfilter(chkc) end
	-- 在发动步骤0时，判定自己场上是否存在表侧表示的「治安战警队」怪兽
	if chk==0 then return Duel.IsExistingTarget(c82977464.mvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 且自己场上存在可用的主要怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 提示玩家选择要移动位置的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(82977464,2))  --"请选择要移动位置的怪兽"
	-- 选择自己场上1只表侧表示的「治安战警队」怪兽作为效果对象
	Duel.SelectTarget(tp,c82977464.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的执行函数
function c82977464.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or not tc:IsControler(tp) then return end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择1个自己场上可用的主要怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 将目标怪兽移动到选择的主要怪兽区域
	Duel.MoveSequence(tc,nseq)
end
