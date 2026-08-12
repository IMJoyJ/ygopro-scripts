--ヘルウェイ・パトロール
-- 效果：
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本等级×100伤害。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只攻击力2000以下的恶魔族怪兽特殊召唤。
function c13521194.initial_effect(c)
	-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本等级×100伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13521194,0))  --"给与伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	-- 检测本次战斗是否为该卡与对方怪兽的战斗，并且对方怪兽被战斗破坏送入墓地
	e1:SetCondition(aux.bdgcon)
	e1:SetTarget(c13521194.damtarget)
	e1:SetOperation(c13521194.damoperation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只攻击力2000以下的恶魔族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(13521194,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡从墓地除外作为发动cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c13521194.sptarget)
	e2:SetOperation(c13521194.spoperation)
	c:RegisterEffect(e2)
end
-- 计算战斗伤害时的目标怪兽等级并设置伤害值
function c13521194.damtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	local m=0
	if a==e:GetHandler() then m=d:GetLevel()*100
	else m=a:GetLevel()*100 end
	-- 设置连锁处理时的伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理时的伤害值为怪兽等级×100
	Duel.SetTargetParam(m)
	-- 设置本次连锁处理的伤害效果信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,m)
end
-- 处理战斗伤害效果
function c13521194.damoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（即伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 筛选手牌中满足条件的恶魔族怪兽
function c13521194.filter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标
function c13521194.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的恶魔族怪兽
		and Duel.IsExistingMatchingCard(c13521194.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁处理的特殊召唤效果信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果
function c13521194.spoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌中选择满足条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c13521194.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
