--斬機ナブラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只电子界族怪兽解放才能发动。从卡组把1只「斩机」怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c53577438.initial_effect(c)
	-- ①：把自己场上1只电子界族怪兽解放才能发动。从卡组把1只「斩机」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53577438,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53577438)
	e1:SetCost(c53577438.cost)
	e1:SetTarget(c53577438.target)
	e1:SetOperation(c53577438.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,53577439)
	-- 设置发动条件：仅当玩家可以进入战斗阶段或正处于战斗阶段时才能发动
	e2:SetCondition(aux.bpcon)
	e2:SetTarget(c53577438.datg)
	e2:SetOperation(c53577438.daop)
	c:RegisterEffect(e2)
end
-- 定义解放过滤函数：检查卡片是否为电子界族且解放后仍有可用的怪兽区域
function c53577438.costfilter(c,tp)
	-- 检查是否为电子界族且该卡解放后仍有可用的怪兽区域（确保特殊召唤有位置）
	return c:IsRace(RACE_CYBERSE) and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 定义代价处理函数：检查并执行解放场上1只电子界族怪兽作为发动代价
function c53577438.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1只符合条件的可解放电子界族怪兽（非上级召唤用）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c53577438.costfilter,1,nil,tp) end
	-- 让玩家选择1只符合条件的电子界族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c53577438.costfilter,1,1,nil,tp)
	-- 以支付代价的原因解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 定义卡组检索过滤函数：检查是否为「斩机」字段且可以被特殊召唤
function c53577438.filter(c,e,tp)
	return c:IsSetCard(0x132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义目标设置函数：检查卡组是否存在符合条件的「斩机」怪兽并设置操作信息
function c53577438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只符合条件的「斩机」怪兽可被特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(c53577438.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽（效果处理时才确定具体卡片，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数：从卡组选择并特殊召唤「斩机」怪兽
function c53577438.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有可用的怪兽区域，若无则终止处理（防止无位置时特殊召唤失败）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的「斩机」怪兽
	local g=Duel.SelectMatchingCard(tp,c53577438.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到玩家场上（不无视召唤条件）
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义目标过滤函数：检查是否为额外怪兽区域的表侧电子界族怪兽且未拥有额外攻击效果
function c53577438.dafilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) and c:GetSequence()>=5
end
-- 定义目标设置函数：选择额外怪兽区域的1只电子界族怪兽作为效果对象
function c53577438.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53577438.dafilter(chkc) end
	-- 检查场上是否存在至少1只符合条件的额外怪兽区域电子界族怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(c53577438.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的额外怪兽区域电子界族怪兽作为当前连锁的效果对象
	Duel.SelectTarget(tp,c53577438.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理函数：给对象怪兽添加本回合可额外攻击怪兽1次的效果
function c53577438.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（额外怪兽区域的电子界族怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
