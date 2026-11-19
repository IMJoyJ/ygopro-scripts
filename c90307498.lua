--E・HERO ネオス・クルーガー
-- 效果：
-- 「元素英雄 新宇侠」＋「于贝尔」
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。给与对方那只对方怪兽的攻击力数值的伤害。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从手卡·卡组把1只「新宇贤者」无视召唤条件特殊召唤。
function c90307498.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：以「元素英雄 新宇侠」(89943723)和「于贝尔」(78371393)作为融合素材（允许使用替代素材）
	aux.AddFusionProcCode2(c,89943723,78371393,true,true)
	-- 记录这张卡文本中记述了「新宇贤者」(5126490)卡名的事实
	aux.AddCodeList(c,5126490)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件值函数为aux.fuslimit，限制只能通过融合召唤方式特殊召唤
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
	-- 这个卡名的②的效果1回合只能使用1次。②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从手卡·卡组把1只「新宇贤者」无视召唤条件特殊召唤。
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
-- ①效果的Condition函数，检查与这张卡战斗的是否为对方控制且攻击力大于0的怪兽
function c90307498.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:GetAttack()>0
end
-- ①效果的Target函数，设置将给与对方相当于该对方怪兽攻击力数值的伤害操作信息
function c90307498.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明将给与对方玩家等于交战对方怪兽当前攻击力的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetBattleTarget():GetAttack())
end
-- ①效果的Operation函数，确认交战的对方怪兽仍在战斗中且表侧表示后，给与对方其攻击力数值的伤害
function c90307498.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToBattle() then
		local atk=tc:GetAttack()
		-- 以效果给与对方玩家等于该对方怪兽攻击力atk的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
-- 过滤函数，筛选卡号为「新宇贤者」(5126490)且可无视召唤条件特殊召唤的怪兽
function c90307498.spfilter(c,e,tp)
	return c:IsCode(5126490) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的Condition函数，检查这张卡离场前是否为表侧表示，且是否因战斗破坏或对方效果离场
function c90307498.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
end
-- ②效果的Target函数，检查怪兽区空格及手卡·卡组存在可特招的「新宇贤者」，并设置特殊召唤操作信息
function c90307498.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己怪兽区是否有可用空格，且手卡·卡组是否存在至少1只满足spfilter的「新宇贤者」
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c90307498.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明将从自己手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的Operation函数，从自己手卡·卡组选择1只「新宇贤者」无视召唤条件特殊召唤
function c90307498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在手卡·卡组中选择1只「新宇贤者」
	local g=Duel.SelectMatchingCard(tp,c90307498.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「新宇贤者」无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
