--古代の機械魔神
-- 效果：
-- 「古代的机械」怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的这张卡不受其他卡的效果影响。
-- ②：自己主要阶段才能发动。给与对方1000伤害。
-- ③：这张卡被战斗破坏送去墓地的场合才能发动。从卡组把1只「古代的机械」怪兽无视召唤条件特殊召唤。
function c87182127.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要2只「古代的机械」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),2,true)
	-- ①：场上的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c87182127.efilter)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87182127,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,87182127)
	e2:SetTarget(c87182127.damtg)
	e2:SetOperation(c87182127.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏送去墓地的场合才能发动。从卡组把1只「古代的机械」怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87182127,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c87182127.condition)
	e3:SetTarget(c87182127.target)
	e3:SetOperation(c87182127.operation)
	c:RegisterEffect(e3)
end
-- 免疫效果的过滤函数：过滤掉非自身卡片发动的效果
function c87182127.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 伤害效果的发动准备与目标确认函数
function c87182127.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的参数值为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁的操作信息：给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的执行函数
function c87182127.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 诱发效果的发动条件：这张卡必须存在于墓地
function c87182127.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤函数：检索卡组中可以无视召唤条件特殊召唤的「古代的机械」怪兽
function c87182127.filter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的发动准备与目标确认函数
function c87182127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「古代的机械」怪兽
		and Duel.IsExistingMatchingCard(c87182127.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行函数
function c87182127.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「古代的机械」怪兽
	local g=Duel.SelectMatchingCard(tp,c87182127.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
