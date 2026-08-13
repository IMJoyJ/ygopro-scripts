--機殻の凍結
-- 效果：
-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻1800/守1000）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果把这张卡特殊召唤的回合，自己场上的「机壳」魔法·陷阱卡不会被效果破坏。
-- ②：这张卡的效果特殊召唤的这张卡在「隐藏的机壳」怪兽上级召唤的场合，可以作为3只的数量解放。
function c20447641.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻1800/守1000）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果把这张卡特殊召唤的回合，自己场上的「机壳」魔法·陷阱卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c20447641.target)
	e1:SetOperation(c20447641.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡在「隐藏的机壳」怪兽上级召唤的场合，可以作为3只的数量解放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20447641,0))  --"用「机壳的冻结」作为3只的数量解放"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCondition(c20447641.ttcon)
	e3:SetTarget(c20447641.tttg)
	e3:SetOperation(c20447641.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e4)
end
-- 定义①效果发动时的Target函数：在发动时校验是否无代价限制、是否有怪兽区空格、以及能否将自己特殊召唤为指定效果怪兽；满足时允许发动。
function c20447641.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区是否还有至少1个空位，用于让这张卡以怪兽形式特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp是否允许将卡号20447641的卡作为「机壳」字段的效果怪兽（机械族·地·4星·攻1800/守1000）特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20447641,0xaa,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 登记本次连锁的特殊召唤操作信息：本效果将把这张卡自身特殊召唤（CATEGORY_SPECIAL_SUMMON），数量为1，供其他卡片检测或响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：确认本卡仍与效果相关且可特殊召唤后，将本卡变成效果怪兽并以表侧表示特殊召唤；成功后设置已用①效果特殊召唤的标记，并给己方场上「机壳」魔法·陷阱卡附加本回合不会被效果破坏的保护效果，最后完成特殊召唤。
function c20447641.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断发动效果的本卡仍然与当前连锁相关（未被无效、离场或失去关联），且玩家仍满足特殊召唤该效果怪兽的条件，满足才继续处理。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,20447641,0xaa,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		-- 尝试将这张卡以正面表示特殊召唤到自己的主要怪兽区：nocheck=true表示不检查召唤条件，nolimit=false表示仍受苏生限制；若特殊召唤成功则继续执行后续处理。
		if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
			c:RegisterFlagEffect(20447641,RESET_EVENT+RESETS_STANDARD,0,1)
			-- ①：这个效果把这张卡特殊召唤的回合，自己场上的「机壳」魔法·陷阱卡不会被效果破坏。②：这张卡的效果特殊召唤的这张卡在「隐藏的机壳」怪兽上级召唤的场合，可以作为3只的数量解放。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetTargetRange(LOCATION_ONFIELD,0)
			e2:SetTarget(c20447641.indtg)
			e2:SetValue(1)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将e2保护效果注册给当前玩家tp，使其作为场地效果持续影响己方场上符合条件的「机壳」魔法·陷阱卡，本回合内不会被效果破坏。
			Duel.RegisterEffect(e2,tp)
		end
		-- 结束特殊召唤的分解处理，完成本次特殊召唤的结算，并触发召唤成功时的时点。
		Duel.SpecialSummonComplete()
	end
end
-- 保护效果的对象筛选函数：判断卡片是否为「机壳」字段的魔法·陷阱卡，满足则获得“不会被效果破坏”的保护。
function c20447641.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xaa)
end
-- ②效果用的素材过滤器：判断卡片是否为本回合通过①效果特殊召唤的「机壳的冻结」（原卡号20447641），且可作为上级召唤的解放，同时带有特殊召唤标记（FlagEffect 20447641不为0）。
function c20447641.ttfilter(c)
	return c:GetOriginalCode()==20447641 and c:IsReleasable(REASON_SUMMON) and c:GetFlagEffect(20447641)~=0
end
-- ②效果的规则替代条件：当玩家对「隐藏的机壳」怪兽进行上级召唤时，若所需解放数不超过3，且自己场上有可用的「机壳的冻结」，则允许用这张卡替代所需解放；c==nil时表示系统询问该规则是否可用，直接返回true。
function c20447641.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定所需解放数量不超过3（这张卡能当作3只数量解放），同时确保召唤后仍有可用怪兽区域（用>-1是为了允许怪兽区全满时解放后腾出位置的情况）。
	return minc<=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认自己主要怪兽区存在至少1张满足ttfilter条件的「机壳的冻结」，可用于这次上级召唤的解放替代。
		and Duel.IsExistingMatchingCard(c20447641.ttfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则替代效果的Target过滤器：只有被上级召唤的怪兽是「隐藏的机壳」字段（0x10aa）时才允许使用这张卡的解放替代效果。
function c20447641.tttg(e,c)
	return c:IsSetCard(0x10aa)
end
-- ②效果的实际处理：提示选择解放素材，从自己主要怪兽区选择1张该卡，将其设为这次召唤的素材，并以“召唤+素材”的理由解放，完成作为3只数量解放的替代。
function c20447641.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 向玩家显示“请选择要解放的卡”的提示，用于选择解放素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 打开选择界面，从自己主要怪兽区中选出1张满足ttfilter条件的「机壳的冻结」作为解放素材（固定选择1张）。
	local g=Duel.SelectMatchingCard(tp,c20447641.ttfilter,tp,LOCATION_MZONE,0,1,1,nil)
	c:SetMaterial(g)
	-- 将选择的「机壳的冻结」解放，解放原因标记为上级召唤的素材（REASON_SUMMON+REASON_MATERIAL），从而完成其作为3只数量解放的替代。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
