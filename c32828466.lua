--Wake Up Your E・HERO
-- 效果：
-- 「元素英雄」融合怪兽＋战士族怪兽1只以上
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300，同1次的战斗阶段中可以向怪兽作出最多有那之内的所用融合怪兽数量的攻击。
-- ②：这张卡和怪兽进行战斗的伤害计算后发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ③：融合召唤的这张卡被破坏的场合发动。从手卡·卡组把1只战士族怪兽特殊召唤。
function c32828466.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为场上·手牌的1只「元素英雄」融合怪兽和1只以上（最多127只）战士族怪兽，且可任意选择一侧作为素材。
	aux.AddFusionProcFunFunRep(c,c32828466.mfilter1,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,127,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数：仅当通过融合召唤方式特殊召唤时才允许此卡特殊召唤，否则不能。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300，同1次的战斗阶段中可以向怪兽作出最多有那之内的所用融合怪兽数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32828466.mtcon)
	e1:SetOperation(c32828466.mtop)
	c:RegisterEffect(e1)
	-- 作为这张卡的融合素材的怪兽数量×300，同1次的战斗阶段中可以向怪兽作出最多有那之内的所用融合怪兽数量的攻击。
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
-- 定义融合素材过滤条件：必须是「元素英雄」字段的融合怪兽，作为融合素材中的那1只「元素英雄」融合怪兽。
function c32828466.mfilter1(c)
	return c:IsFusionSetCard(0x3008) and c:IsFusionType(TYPE_FUSION)
end
-- 在融合召唤时统计此卡的素材总数量ct1以及素材中融合怪兽的数量ct2，并将两个数量存入e1的标签中，供特殊召唤成功后的效果计算使用。
function c32828466.valcheck(e,c)
	local ct1=c:GetMaterialCount()
	local ct2=c:GetMaterial():FilterCount(Card.IsFusionType,nil,TYPE_FUSION)
	e:GetLabelObject():SetLabel(ct1,ct2)
end
-- 发动条件：此卡是融合召唤成功，且已通过素材检查记录了素材数量（素材数大于0）。
function c32828466.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
-- 融合召唤成功时，根据记录的素材数量为此卡赋予攻击力上升效果（素材总数×300）和额外怪兽攻击次数（素材中融合怪兽数量-1次额外攻击，即可攻击素材融合怪兽数量次）。
function c32828466.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1,ct2=e:GetLabel()
	-- 这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(ct1*300)
	c:RegisterEffect(e1)
	-- 同1次的战斗阶段中可以向怪兽作出最多有那之内的所用融合怪兽数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(ct2-1)
	c:RegisterEffect(e2)
end
-- 伤害计算后发动条件：本卡拥有战斗对象，且该战斗对象仍与这次战斗相关（尚未离场或无法关联）。
function c32828466.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsRelateToBattle()
end
-- 效果发动时不取对象；设置操作信息：将战斗对象确定为破坏对象，并预定给对方造成该战斗对象原本攻击力数值的伤害。
function c32828466.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 设置破坏的操作信息：确认要破坏的对象为战斗对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	-- 设置伤害的操作信息：确认要给对方造成伤害，数值为战斗对象的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
-- 效果处理：若战斗对象仍与战斗相关，则将其破坏；破坏成功后若其原本攻击力大于0，则给对方造成等同于该原本攻击力数值的效果伤害。
function c32828466.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断战斗对象仍与战斗相关，并执行破坏；若破坏成功则继续处理后续伤害。
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
		local dam=bc:GetBaseAttack()
		-- 若原本攻击力大于0，则给对方玩家造成该数值的效果伤害。
		if dam>0 then Duel.Damage(1-tp,dam,REASON_EFFECT) end
	end
end
-- ③的发动条件：此卡在怪兽区被破坏，且此前是通过融合召唤出场。
function c32828466.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果发动时设置操作信息：从手卡·卡组特殊召唤1只战士族怪兽。
function c32828466.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息：从自己的手卡·卡组特殊召唤1只卡，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤可特殊召唤的怪兽：必须是战士族，且能够被当前效果特殊召唤。
function c32828466.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：若自己主怪兽区有空位，让玩家从手卡·卡组选择1只符合条件的战士族怪兽，并表侧攻击表示特殊召唤到自己场上。
function c32828466.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区是否有空位，若没有则不能特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示框，提示玩家从手卡·卡组选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选择1只满足 spfilter 条件（战士族且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c32828466.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择到的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
