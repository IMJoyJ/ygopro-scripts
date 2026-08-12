--E・HERO ネオス・クルーガー
-- 效果：
-- 「元素英雄 新宇侠」＋「于贝尔」
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。给与对方那只对方怪兽的攻击力数值的伤害。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从手卡·卡组把1只「新宇贤者」无视召唤条件特殊召唤。
function c90307498.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「元素英雄 新宇侠」和「于贝尔」的融合召唤手续
	aux.AddFusionProcCode2(c,89943723,78371393,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制这张卡只能通过融合召唤来特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。给与对方那只对方怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90307498,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c90307498.damcon)
	e1:SetTarget(c90307498.damtg)
	e1:SetOperation(c90307498.damop)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从手卡·卡组把1只「新宇贤者」无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90307498,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,90307498)
	e2:SetCondition(c90307498.spcon)
	e2:SetTarget(c90307498.sptg)
	e2:SetOperation(c90307498.spop)
	c:RegisterEffect(e2)
end
c90307498.material_setcode=0x8
-- 效果①的发动条件：伤害计算前，存在与这张卡进行战斗的对方怪兽，且该怪兽的攻击力大于0
function c90307498.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:GetAttack()>0
end
-- 效果①的靶向/发动准备：在发动时，设置给与对方相当于对方战斗怪兽攻击力数值伤害的操作信息
function c90307498.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置给与对方相当于对方战斗怪兽攻击力数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetBattleTarget():GetAttack())
end
-- 效果①的效果处理：若对方战斗怪兽仍存在且在场上表侧表示，则给与对方其攻击力数值的伤害
function c90307498.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToBattle() then
		local atk=tc:GetAttack()
		-- 给与对方玩家相当于该怪兽攻击力数值的效果伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
-- 过滤函数：检索手卡或卡组中卡名为「新宇贤者」且可以无视召唤条件特殊召唤的怪兽
function c90307498.spfilter(c,e,tp)
	return c:IsCode(5126490) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动条件：表侧表示的这张卡被战斗破坏，或者因对方的效果从自己场上离开
function c90307498.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
end
-- 效果②的靶向/发动准备：检查自身怪兽区域是否有空位，且手卡或卡组中是否存在可特殊召唤的「新宇贤者」，并设置特殊召唤的操作信息
function c90307498.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位，且手卡或卡组中是否存在可特殊召唤的「新宇贤者」
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c90307498.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置从手卡或卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理：从手卡或卡组选择1只「新宇贤者」无视召唤条件特殊召唤到场上
function c90307498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身怪兽区域是否有空位，若无空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1只符合条件的「新宇贤者」
	local g=Duel.SelectMatchingCard(tp,c90307498.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
