--竜魔導騎士ブラック・マジシャン
-- 效果：
-- 「黑魔术师」＋7星以上的龙族·战士族怪兽
-- ①：自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，自己怪兽战斗破坏对方怪兽时才能发动。给与对方那只破坏的怪兽的原本攻击力数值的伤害。
-- ③：这张卡被破坏的场合才能发动。「黑魔术师」「龙骑士 盖亚」各1只从自己的手卡·卡组·额外卡组·墓地选出特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合素材设定、贯穿效果、战斗破坏对方怪兽时给予伤害的效果、以及被破坏时特殊召唤特定怪兽的效果
function s.initial_effect(c)
	-- 注册该卡记有「龙骑士 盖亚」（卡号66889139）的卡名
	aux.AddCodeList(c,66889139)
	c:EnableReviveLimit()
	-- 设定融合素材为「黑魔术师」（卡号46986414）加上1只满足过滤条件s.mfilter的怪兽
	aux.AddFusionProcCodeFun(c,46986414,s.mfilter,1,true,true)
	-- ①：自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己怪兽战斗破坏对方怪兽时才能发动。给与对方那只破坏的怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。「黑魔术师」「龙骑士 盖亚」各1只从自己的手卡·卡组·额外卡组·墓地选出特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：等级7星以上且是龙族或战士族的怪兽
function s.mfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON+RACE_WARRIOR)
end
-- 效果②的发动条件：自己怪兽战斗破坏对方怪兽时
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return #eg==1 and rc:IsControler(tp) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE)
end
-- 效果②的发动准备与目标确认：确认被破坏怪兽的原本攻击力大于0，并将其设为效果处理对象，注册给予伤害的操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=eg:GetFirst()
	if chk==0 then return bc:GetBaseAttack()>0 end
	-- 将被战斗破坏的怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(bc)
	-- 注册效果处理信息，表示该效果会给予对方相当于该怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
-- 效果②的效果处理：给予对方被破坏怪兽原本攻击力数值的伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果处理对象的被破坏怪兽
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToEffect(e) then
		-- 给予对方玩家相当于该怪兽原本攻击力数值的效果伤害
		Duel.Damage(1-tp,bc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 特殊召唤过滤条件1：卡名为「黑魔术师」且可以被特殊召唤，并且此时卡组等区域还存在可以被特殊召唤的「龙骑士 盖亚」
function s.spfilter1(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡、卡组、额外卡组、墓地中是否存在除当前卡以外、满足过滤条件2（即「龙骑士 盖亚」）的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 特殊召唤过滤条件2：卡名为「龙骑士 盖亚」且可以被特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsCode(66889139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与目标确认：确认是否存在可特殊召唤的「黑魔术师」和「龙骑士 盖亚」，且自己场上有2个以上的空怪兽位，且不受青眼精灵龙等限制同时特召数量的效果影响
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡、卡组、额外卡组、墓地中是否存在满足特殊召唤条件1（「黑魔术师」）的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 注册效果处理信息，表示该效果会从手卡、卡组、额外卡组、墓地特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果③的效果处理：从手卡、卡组、额外卡组、墓地各选出1只「黑魔术师」和「龙骑士 盖亚」特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的主要怪兽区域空位不足2个，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡、卡组、额外卡组、墓地中选择1只满足条件1（「黑魔术师」）的怪兽（受王家长眠之谷影响）
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡、卡组、额外卡组、墓地中选择1只满足条件2（「龙骑士 盖亚」）的怪兽（排除已选的卡，且受王家长眠之谷影响）
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if #g1==2 then
		-- 将选出的2只怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
