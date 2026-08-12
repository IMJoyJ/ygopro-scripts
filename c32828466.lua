--Wake Up Your E・HERO
-- 效果：
-- 「元素英雄」融合怪兽＋战士族怪兽1只以上
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300，同1次的战斗阶段中可以向怪兽作出最多有那之内的所用融合怪兽数量的攻击。
-- ②：这张卡和怪兽进行战斗的伤害计算后发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ③：融合召唤的这张卡被破坏的场合发动。从手卡·卡组把1只战士族怪兽特殊召唤。
function c32828466.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的融合怪兽和1到127只战士族怪兽作为融合素材
	aux.AddFusionProcFunFunRep(c,c32828466.mfilter1,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,127,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过融合召唤方式特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300，同1次的战斗阶段中可以向怪兽作出最多有那之内的所用融合怪兽数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32828466.mtcon)
	e1:SetOperation(c32828466.mtop)
	c:RegisterEffect(e1)
	-- ③：融合召唤的这张卡被破坏的场合发动。从手卡·卡组把1只战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c32828466.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡和怪兽进行战斗的伤害计算后发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32828466,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c32828466.descon)
	e3:SetTarget(c32828466.destg)
	e3:SetOperation(c32828466.desop)
	c:RegisterEffect(e3)
	-- ③：融合召唤的这张卡被破坏的场合发动。从手卡·卡组把1只战士族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(32828466,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c32828466.spcon)
	e4:SetTarget(c32828466.sptg)
	e4:SetOperation(c32828466.spop)
	c:RegisterEffect(e4)
end
c32828466.material_setcode=0x8
-- 过滤满足条件的融合怪兽，即属于元素英雄系列且为融合怪兽
function c32828466.mfilter1(c)
	return c:IsFusionSetCard(0x3008) and c:IsFusionType(TYPE_FUSION)
end
-- 记录融合素材数量和融合怪兽数量，用于后续效果处理
function c32828466.valcheck(e,c)
	local ct1=c:GetMaterialCount()
	local ct2=c:GetMaterial():FilterCount(Card.IsFusionType,nil,TYPE_FUSION)
	e:GetLabelObject():SetLabel(ct1,ct2)
end
-- 判断该卡是否为融合召唤且融合素材数量大于0
function c32828466.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
-- 根据融合素材数量增加攻击力，并允许额外攻击次数
function c32828466.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1,ct2=e:GetLabel()
	-- 增加攻击力，数值为融合素材数量乘以300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(ct1*300)
	c:RegisterEffect(e1)
	-- 增加额外攻击次数，次数为融合怪兽数量减一
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(ct2-1)
	c:RegisterEffect(e2)
end
-- 判断战斗对象是否有效
function c32828466.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsRelateToBattle()
end
-- 设置破坏和伤害的连锁操作信息
function c32828466.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 设置破坏目标为战斗怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	-- 设置给与对方伤害的数值为战斗怪兽的原本攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
-- 执行战斗后破坏对方怪兽并造成伤害
function c32828466.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断战斗怪兽是否有效并成功破坏
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
		local dam=bc:GetBaseAttack()
		-- 若伤害值大于0，则给与对方相应伤害
		if dam>0 then Duel.Damage(1-tp,dam,REASON_EFFECT) end
	end
end
-- 判断该卡是否为融合召唤且从场上被破坏
function c32828466.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置特殊召唤的连锁操作信息
function c32828466.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置从手卡或卡组特殊召唤1只战士族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤满足条件的战士族怪兽，可特殊召唤
function c32828466.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择并特殊召唤符合条件的战士族怪兽
function c32828466.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的战士族怪兽
	local g=Duel.SelectMatchingCard(tp,c32828466.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
