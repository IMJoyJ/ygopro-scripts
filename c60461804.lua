--D-HERO デストロイフェニックスガイ
-- 效果：
-- 6星以上的「英雄」怪兽＋「命运英雄」怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上的怪兽的攻击力下降自己墓地的「英雄」卡数量×200。
-- ②：自己·对方回合可以发动。自己场上1张卡和场上1张卡破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。下个回合的准备阶段，从自己墓地把1只「命运英雄」怪兽特殊召唤。
function c60461804.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要1只满足matfilter条件的怪兽和1只「命运英雄」怪兽作为素材
	aux.AddFusionProcFun2(c,c60461804.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc008),true)
	-- ①：对方场上的怪兽的攻击力下降自己墓地的「英雄」卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c60461804.atkval)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合可以发动。自己场上1张卡和场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60461804,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,60461804)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c60461804.destg)
	e2:SetOperation(c60461804.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。下个回合的准备阶段，从自己墓地把1只「命运英雄」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60461804,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,60461805)
	e3:SetCondition(c60461804.regcon)
	e3:SetOperation(c60461804.regop)
	c:RegisterEffect(e3)
end
c60461804.material_setcode=0xc008
-- 融合素材过滤条件：属于「英雄」系列且等级在6星以上的怪兽
function c60461804.matfilter(c)
	return c:IsFusionSetCard(0x8) and c:IsLevelAbove(6)
end
-- 攻击力下降值的计算函数
function c60461804.atkval(e,c)
	-- 返回自己墓地「英雄」卡数量乘以-200的数值
	return Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,0x8)*-200
end
-- 破坏卡片过滤条件1：场上存在除自身以外至少1张卡
function c60461804.desfilter1(c)
	-- 检查场上是否存在至少1张除卡片c以外的卡
	return Duel.IsExistingMatchingCard(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 破坏效果的发动准备与合法性检测（Target函数）
function c60461804.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足过滤条件1的卡（即自己场上有卡，且场上还有其他卡可供破坏）
	if chk==0 then return Duel.IsExistingMatchingCard(c60461804.desfilter1,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 获取双方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁中的操作信息：破坏场上的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 破坏效果的处理逻辑（Operation函数）
function c60461804.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张要破坏的卡
	local g1=Duel.SelectMatchingCard(tp,c60461804.desfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g1==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上（除第一张选中的卡外）选择1张要破坏的卡
	local g2=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1)
	g1:Merge(g2)
	-- 给选中的卡片组显示被选为对象的动画效果
	Duel.HintSelection(g1)
	-- 因效果破坏选中的卡片
	Duel.Destroy(g1,REASON_EFFECT)
end
-- 效果③的发动条件：这张卡被战斗或效果破坏
function c60461804.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 效果③的处理逻辑：注册一个在下个回合准备阶段发动特殊召唤效果的延迟效果
function c60461804.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 下个回合的准备阶段，从自己墓地把1只「命运英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 将当前回合数记录在效果的Label中，用于后续判断是否为“下个回合”
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(c60461804.spcon)
	e1:SetOperation(c60461804.spop)
	-- 判断当前阶段是否在准备阶段或之前（如果是，则“下个回合”的准备阶段需要持续2个准备阶段的时点限制）
	if Duel.GetCurrentPhase()<=PHASE_STANDBY then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	end
	-- 将该延迟效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤怪兽的过滤条件：属于「命运英雄」系列且可以被特殊召唤
function c60461804.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 延迟特殊召唤效果的发动条件
function c60461804.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否不等于注册时的回合（即至少到了下个回合），且自己场上有可用的怪兽区域
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只满足特殊召唤条件的「命运英雄」怪兽
		and Duel.IsExistingMatchingCard(c60461804.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
-- 延迟特殊召唤效果的处理逻辑
function c60461804.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了「命运英雄 毁灭凤凰人」的效果
	Duel.Hint(HINT_CARD,0,60461804)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「命运英雄」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c60461804.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
