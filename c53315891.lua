--合神竜ティマイオス
-- 效果：
-- 「传说的骑士 克里底亚」＋「传说的骑士 赫谟」＋「传说的骑士 蒂迈欧」
-- 把自己场上的上记卡送去墓地的场合才能特殊召唤（不需要「融合」）。
-- ①：这张卡不受其他卡的效果影响。
-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力·守备力变成和场上的怪兽的最高攻击力相同。
-- ③：这张卡被战斗破坏时才能发动。选自己的手卡·卡组·墓地3只「传说的骑士」怪兽无视召唤条件特殊召唤。
function c53315891.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以卡号80019195（传说的骑士 克里底亚）、85800949（传说的骑士 赫谟）、84565800（传说的骑士 蒂迈欧）为融合素材的融合召唤手续，定义其三体素材组合。
	aux.AddFusionProcCode3(c,80019195,85800949,84565800,true,true)
	-- 为这张卡添加接触融合手续：将自己场上能作为代价送去墓地的上记素材怪兽送去墓地，从额外卡组特殊召唤这张卡，实现无需「融合」魔法。
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_ONFIELD,0,Duel.SendtoGrave,REASON_COST)
	-- 「传说的骑士 克里底亚」＋「传说的骑士 赫谟」＋「传说的骑士 蒂迈欧」 把自己场上的上记卡送去墓地的场合才能特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡不受其他卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c53315891.efilter)
	c:RegisterEffect(e3)
	-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力·守备力变成和场上的怪兽的最高攻击力相同。
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
	-- ③：这张卡被战斗破坏时才能发动。选自己的手卡·卡组·墓地3只「传说的骑士」怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetTarget(c53315891.sptg)
	e5:SetOperation(c53315891.spop)
	c:RegisterEffect(e5)
end
-- 作为①效果的免疫判定函数：当某个效果的所有者不是这张卡的所有者时，该效果不能影响这张卡，即只免疫其他卡的效果，自己效果仍可适用。
function c53315891.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- ②效果的发动条件判定：判断这张卡是否为攻击怪兽或攻击对象，即是否在“进行战斗的伤害计算时”。
function c53315891.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回真当且仅当这张卡是本次战斗的攻击方或攻击对象，确认该卡正在进行战斗。
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- ②效果发动时的合法性检测：场上存在其他表侧怪兽，且这张卡当前攻击力未达到场上最高攻击力时才满足发动条件（若已是最高则不能发动）。
function c53315891.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取双方场上除这张卡以外的所有表侧表示怪兽，用于下一步计算场上最高攻击力。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		if g:GetCount()==0 then return false end
		local g1,atk=g:GetMaxGroup(Card.GetAttack)
		return not c:IsAttack(atk)
	end
end
-- ②效果处理：取得场上表侧怪兽的最高攻击力，将这张卡的攻击力和守备力分别设置为该数值（若该卡仍关联此效果且表侧表示）。
function c53315891.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上除这张卡以外的所有表侧表示怪兽，用于计算当前场上最高攻击力。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if g:GetCount()==0 then return end
	local g1,atk=g:GetMaxGroup(Card.GetAttack)
	if c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
		-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力·守备力变成和场上的怪兽的最高攻击力相同。
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
-- ③效果的素材过滤：选择持有「传说的骑士」字段（0xa0）且可以被效果无视召唤条件（但遵守苏生限制）特殊召唤的怪兽。
function c53315891.spfilter(c,e,tp)
	return c:IsSetCard(0xa0) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③效果发动条件：己方不受青眼精灵龙影响（不能同时特殊召唤2只以上）、主要怪兽区至少3个空格，且手卡/卡组/墓地存在至少3只符合条件的「传说的骑士」怪兽。
function c53315891.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求己方主要怪兽区至少存在3个可用空格，以保证可以特殊召唤3只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		-- 确认在手卡（0x2）、卡组（0x1）、墓地（0x10）合计0x13区域中存在至少3张满足spfilter条件的「传说的骑士」怪兽。
		and Duel.IsExistingMatchingCard(c53315891.spfilter,tp,0x13,0,3,nil,e,tp) end
	-- 向系统登记本次效果将特殊召唤3只怪兽，来源为手卡·卡组·墓地（0x13），用于相关卡片（如星尘龙）的连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0x13)
end
-- ③效果处理：再次确认没有青眼精灵龙限制且区域足够后，从手卡·卡组·墓地中选出3只「传说的骑士」怪兽，无视召唤条件以表侧攻击表示特殊召唤到己方场上。
function c53315891.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若处理时己方主要怪兽区空格不足3个，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取手卡·卡组·墓地中满足条件的「传说的骑士」怪兽集合，并用NecroValleyFilter过滤掉受王家长眠之谷影响的卡，确保可选范围正确。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c53315891.spfilter),tp,0x13,0,nil,e,tp)
	if g:GetCount()>2 then
		-- 提示玩家从候选卡中选择要特殊召唤的卡（显示选择框）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选择的3只怪兽以表侧攻击表示特殊召唤到己方场上，nocheck=true表示无视召唤条件，nolimit=false表示仍遵守苏生限制。
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end
