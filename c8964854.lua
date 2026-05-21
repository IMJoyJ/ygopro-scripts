--コンビネーション・アタック
-- 效果：
-- 有同盟怪兽装备的怪兽进行过战斗的战斗阶段时才能发动。选择1只有同盟怪兽装备并进行过战斗的怪兽，把装备的同盟解除。选择的怪兽在这个回合可以再1次攻击。
function c8964854.initial_effect(c)
	-- 有同盟怪兽装备的怪兽进行过战斗的战斗阶段时才能发动。选择1只有同盟怪兽装备并进行过战斗的怪兽，把装备的同盟解除。选择的怪兽在这个回合可以再1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c8964854.condition)
	e1:SetTarget(c8964854.target)
	e1:SetOperation(c8964854.operation)
	c:RegisterEffect(e1)
end
c8964854.has_text_type=TYPE_UNION
-- 定义效果的发动条件函数：当前是否为战斗阶段。
function c8964854.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否在战斗阶段开始到战斗阶段结束之间。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义过滤函数：筛选进行过战斗且装备有同盟怪兽的怪兽。
function c8964854.filter(c,e,tp)
	-- 检查怪兽是否进行过攻击，且其装备卡中是否存在可特殊召唤的同盟怪兽。
	return c:GetAttackAnnouncedCount()>0 and Duel.IsExistingMatchingCard(c8964854.eqfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,c)
end
-- 定义过滤函数：筛选装备在目标怪兽上的、处于同盟状态且可以特殊召唤的同盟怪兽。
function c8964854.eqfilter(c,e,tp,ec)
	local op=c:GetOwner()
	return c:IsHasEffect(EFFECT_UNION_STATUS) and c:GetEquipTarget()==ec
		-- 检查同盟怪兽持有者的怪兽区域是否有空位，且该同盟怪兽是否可以特殊召唤。
		and Duel.GetLocationCount(op,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,op)
end
-- 定义效果的目标选择与操作信息设置函数。
function c8964854.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c8964854.filter(chkc,e,tp) end
	-- 在效果发动时，检查场上是否存在至少1只满足条件的、可作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c8964854.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只进行过战斗且装备有同盟怪兽的怪兽作为效果对象。
	Duel.SelectTarget(tp,c8964854.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置效果处理信息：从魔陷区特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
-- 定义效果处理函数：解除同盟装备并特殊召唤，使对象怪兽可以再1次攻击。
function c8964854.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local op=tc:GetOwner()
	-- 检查对象怪兽是否表侧表示存在、是否仍受此效果影响，且其持有者的怪兽区域是否有空位。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.GetLocationCount(op,LOCATION_MZONE)>0 then
		-- 获取装备在对象怪兽上的同盟怪兽组。
		local g=Duel.GetMatchingGroup(c8964854.eqfilter,tp,LOCATION_SZONE,0,nil,e,tp,tc)
		-- 将同盟怪兽特殊召唤到其持有者的场上（解除装备），并判断是否特殊召唤成功。
		if Duel.SpecialSummon(g,0,tp,op,false,false,POS_FACEUP)>0 then
			-- 选择的怪兽在这个回合可以再1次攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(tc:GetAttackAnnouncedCount())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
