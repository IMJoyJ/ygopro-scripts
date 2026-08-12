--ヴァンパイア・レッドバロン
-- 效果：
-- ①：1回合1次，支付1000基本分，以对方场上1只怪兽和这张卡以外的自己场上1只「吸血鬼」怪兽为对象才能发动。那2只怪兽的控制权交换。
-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
function c6917479.initial_effect(c)
	-- ①：1回合1次，支付1000基本分，以对方场上1只怪兽和这张卡以外的自己场上1只「吸血鬼」怪兽为对象才能发动。那2只怪兽的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6917479,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c6917479.ctcost)
	e1:SetTarget(c6917479.cttg)
	e1:SetOperation(c6917479.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c6917479.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6917479,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c6917479.spcon)
	e3:SetTarget(c6917479.sptg)
	e3:SetOperation(c6917479.spop)
	c:RegisterEffect(e3)
end
-- 支付1000基本分Cost的检查与支付
function c6917479.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤对方场上可以改变控制权且交换后不导致怪兽区域超限的怪兽
function c6917479.ctfilter1(c)
	local tp=c:GetControler()
	-- 过滤可以改变控制权，且该卡离开后能为控制权转移提供可用怪兽区域的怪兽
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤自己场上表侧表示的「吸血鬼」怪兽且可以改变控制权、交换后不导致怪兽区域超限的怪兽
function c6917479.ctfilter2(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x8e) and c:IsAbleToChangeControler()
		-- 且该卡离开后能为控制权转移提供可用怪兽区域
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 交换控制权效果的发动准备（检查与选择对象）
function c6917479.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c6917479.ctfilter1,tp,0,LOCATION_MZONE,1,nil)
		-- 并且自己场上是否存在这张卡以外的满足条件的「吸血鬼」怪兽
		and Duel.IsExistingTarget(c6917479.ctfilter2,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽作为对象
	local g1=Duel.SelectTarget(tp,c6917479.ctfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只这张卡以外的「吸血鬼」怪兽作为对象
	local g2=Duel.SelectTarget(tp,c6917479.ctfilter2,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	g1:Merge(g2)
	-- 设置效果处理信息为交换这2只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 交换控制权效果的执行
function c6917479.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这2只怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
-- 在这张卡战斗破坏怪兽时，为这张卡注册一个持续到战斗阶段结束的标记
function c6917479.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(6917479,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 检查这张卡是否在当前战斗阶段战斗破坏过怪兽（是否存在对应的标记）
function c6917479.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(6917479)~=0
end
-- 过滤本回合被这张卡战斗破坏并送去墓地、且可以特殊召唤的怪兽
function c6917479.spfilter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（检查与设置操作信息）
function c6917479.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且双方墓地中是否存在被这张卡战斗破坏的怪兽
		and Duel.IsExistingMatchingCard(c6917479.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 获取双方墓地中所有被这张卡战斗破坏的怪兽
	local g=Duel.GetMatchingGroup(c6917479.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 设置效果处理信息为从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行
function c6917479.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取双方墓地中不受「王家长眠之谷」影响的被破坏怪兽
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c6917479.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
