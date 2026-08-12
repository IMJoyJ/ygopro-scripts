--合神竜ティマイオス
-- 效果：
-- 「传说的骑士 克里底亚」＋「传说的骑士 赫谟」＋「传说的骑士 蒂迈欧」
-- 把自己场上的上记卡送去墓地的场合才能特殊召唤（不需要「融合」）。
-- ①：这张卡不受其他卡的效果影响。
-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力·守备力变成和场上的怪兽的最高攻击力相同。
-- ③：这张卡被战斗破坏时才能发动。选自己的手卡·卡组·墓地3只「传说的骑士」怪兽无视召唤条件特殊召唤。
function c53315891.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为80019195、85800949、84565800的3只怪兽作为融合素材
	aux.AddFusionProcCode3(c,80019195,85800949,84565800,true,true)
	-- 添加接触融合特殊召唤规则，要求将自己场上的怪兽送去墓地作为召唤代价
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_ONFIELD,0,Duel.SendtoGrave,REASON_COST)
	-- ①：这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力·守备力变成和场上的怪兽的最高攻击力相同。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c53315891.efilter)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗破坏时才能发动。选自己的手卡·卡组·墓地3只「传说的骑士」怪兽无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c53315891.atkcon)
	e4:SetTarget(c53315891.atktg)
	e4:SetOperation(c53315891.atkop)
	c:RegisterEffect(e4)
	-- 将自己场上的上记卡送去墓地的场合才能特殊召唤（不需要「融合」）。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetTarget(c53315891.sptg)
	e5:SetOperation(c53315891.spop)
	c:RegisterEffect(e5)
end
-- 效果过滤函数，用于判断是否免疫某个效果
function c53315891.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 判断是否为攻击怪兽或被攻击怪兽
function c53315891.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为攻击怪兽或被攻击怪兽
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 设置攻击力变化效果的发动条件
function c53315891.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取场上所有正面表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		if g:GetCount()==0 then return false end
		local g1,atk=g:GetMaxGroup(Card.GetAttack)
		return not c:IsAttack(atk)
	end
end
-- 设置攻击力和守备力变化效果
function c53315891.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if g:GetCount()==0 then return end
	local g1,atk=g:GetMaxGroup(Card.GetAttack)
	if c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
		-- 将攻击力设定为指定值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
-- 过滤函数，用于筛选「传说的骑士」卡组并可特殊召唤
function c53315891.spfilter(c,e,tp)
	return c:IsSetCard(0xa0) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的发动条件
function c53315891.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		-- 检查自己手卡·卡组·墓地是否存在至少3只符合条件的怪兽
		and Duel.IsExistingMatchingCard(c53315891.spfilter,tp,0x13,0,3,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0x13)
end
-- 执行特殊召唤操作
function c53315891.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取满足条件的「传说的骑士」怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c53315891.spfilter),tp,0x13,0,nil,e,tp)
	if g:GetCount()>2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选中的卡以指定方式特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end
