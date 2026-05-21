--HSR魔剣ダーマ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「高速疾行机人 魔剑玉」的②③的效果1回合各能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：把自己墓地1只机械族怪兽除外才能发动。给与对方500伤害。
-- ③：这张卡在墓地存在，自己场上没有卡存在的场合，自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果发动的回合，自己不能通常召唤。
function c97007933.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- ②：把自己墓地1只机械族怪兽除外才能发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97007933,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,97007933)
	e2:SetCost(c97007933.damcost)
	e2:SetTarget(c97007933.damtg)
	e2:SetOperation(c97007933.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，自己场上没有卡存在的场合，自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果发动的回合，自己不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97007933,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,97007934)
	e3:SetCondition(c97007933.spcon)
	e3:SetCost(c97007933.spcost)
	e3:SetTarget(c97007933.sptg)
	e3:SetOperation(c97007933.spop)
	c:RegisterEffect(e3)
end
-- 过滤自身墓地可作为发动代价除外的机械族怪兽
function c97007933.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价：除外墓地1只机械族怪兽
function c97007933.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97007933.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只满足条件的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,c97007933.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的靶向与操作信息注册：给与对方500伤害
function c97007933.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为500
	Duel.SetTargetParam(500)
	-- 注册效果处理信息：给与对方500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果②的实际处理：给与对方500伤害
function c97007933.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果③的发动条件：自己场上没有卡存在
function c97007933.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的卡片数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
-- 效果③的代价：本回合不能通常召唤
function c97007933.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 这个效果发动的回合，自己不能通常召唤。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册本回合不能通常召唤（召唤）的限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册本回合不能通常召唤（盖放）的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果③的靶向与操作信息注册：自身特殊召唤
function c97007933.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 注册效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的实际处理：将自身特殊召唤
function c97007933.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
