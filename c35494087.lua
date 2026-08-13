--SRビードロ・ドクロ
-- 效果：
-- 「疾行机人 噗噗噔骷髅」的③的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段，从额外卡组特殊召唤的怪兽在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡不会被和通常召唤的怪兽的战斗破坏。
-- ③：这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ④：自己场上有「疾行机人」怪兽以外的表侧表示怪兽存在的场合这张卡破坏。
function c35494087.initial_effect(c)
	-- ①：自己·对方的准备阶段，从额外卡组特殊召唤的怪兽在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35494087,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c35494087.spcon)
	e1:SetTarget(c35494087.sptg)
	e1:SetOperation(c35494087.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和通常召唤的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c35494087.indval)
	c:RegisterEffect(e2)
	-- 「疾行机人 噗噗噔骷髅」的③的效果1回合只能使用1次。③：这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetValue(c35494087.refval)
	c:RegisterEffect(e3)
	-- ④：自己场上有「疾行机人」怪兽以外的表侧表示怪兽存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c35494087.sdcon)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件函数：检查对方场上是否存在从额外卡组特殊召唤的怪兽，若存在则满足发动条件。
function c35494087.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 以当前玩家为视角，检查对方主要怪兽区是否存在至少1只召唤位置为额外卡组的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
-- ①效果发动时（chk==0）的合法性检查：确认自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c35494087.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区的空位数量是否大于0，即是否有可用区域来特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁操作信息：本次效果包含特殊召唤，对象为这张卡自身，数量为1，供系统及相关卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时：获取这张卡，如果它仍与效果关联（未被无效或离场），则将其特殊召唤到自己场上。
function c35494087.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其控制者（tp）的场上，不检查召唤条件和苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的判定函数：如果战斗对象是通常召唤的怪兽，则返回 true，表示这张卡不会被该怪兽战斗破坏。
function c35494087.indval(e,c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- ③效果的反射判定：通过卡牌自身与玩家的标识状态决定本次战斗伤害是否由对方代受；有自身标识时转移标识并反射，无标识且玩家无标识时给自身记录标识并反射，否则不反射，以此实现每回合使用次数的限制。
function c35494087.refval(e,c)
	if e:GetHandler():GetFlagEffect(35494087)~=0 then
		-- 给这张卡的控制者注册一个到结束阶段重置的标识，用于记录该反射效果已在本回合使用过，防止后续伤害继续触发。
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(),35494087,RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():ResetFlagEffect(35494087)
		return true
	-- 当此卡自身没有使用标识且控制者也没有使用标识时，进入分支，表示本次可以反射，并给卡注册使用标识。
	elseif Duel.GetFlagEffect(e:GetHandlerPlayer(),35494087)==0 then
		e:GetHandler():RegisterFlagEffect(35494087,0,0,1)
		return true
	else return false end
end
-- ④效果的过滤函数：筛选表侧表示且不属于「疾行机人」系列的怪兽。
function c35494087.sdfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x2016)
end
-- ④效果的适用条件函数：检查自己场上是否有表侧表示且非「疾行机人」系列的怪兽存在；若有，则这张卡因自身效果破坏。
function c35494087.sdcon(e)
	-- 返回自己主要怪兽区是否存在至少1张满足 sdfilter 条件的怪兽。
	return Duel.IsExistingMatchingCard(c35494087.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
