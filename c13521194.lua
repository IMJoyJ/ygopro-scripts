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
	-- 设置①效果的发动条件：此卡战斗破坏怪兽并将其送去墓地时满足条件（由aux.bdgcon检测）。
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
	-- 设置②效果的发动代价：把墓地的这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c13521194.sptarget)
	e2:SetOperation(c13521194.spoperation)
	c:RegisterEffect(e2)
end
-- ①效果的target处理：判定被战斗破坏的对方怪兽，计算其原本等级×100的伤害值，并将对象玩家设为对方。
function c13521194.damtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取进行战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取战斗的攻击目标怪兽。
	local d=Duel.GetAttackTarget()
	local m=0
	if a==e:GetHandler() then m=d:GetLevel()*100
	else m=a:GetLevel()*100 end
	-- 将对象玩家设为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算出的伤害数值m设置为连锁对象参数，供后续处理使用。
	Duel.SetTargetParam(m)
	-- 设置操作信息：声明本连锁含伤害效果，预定对对方造成m点伤害（目标不取对象，故target为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,m)
end
-- ①效果的处理函数：实际给对方玩家造成之前设定好的伤害。
function c13521194.damoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家p和伤害数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式，向对象玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ②的特殊召唤筛选函数：检查怪兽是否攻击力2000以下、恶魔族且能够被特殊召唤。
function c13521194.filter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与目标设定：确认自己场上有可用怪兽区且手牌存在符合条件的恶魔族怪兽，并设置特殊召唤的操作信息。
function c13521194.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：手牌存在至少1只满足filter（攻击力2000以下·恶魔族·可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c13521194.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果会将1张手牌怪兽特殊召唤，目标在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理函数：处理时若仍有可用怪兽区，则从手牌选择1只符合条件的恶魔族怪兽表侧表示特殊召唤。
function c13521194.spoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上有可用怪兽区，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1张满足filter的恶魔族怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c13521194.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的那只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
