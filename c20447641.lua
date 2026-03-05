--機殻の凍結
-- 效果：
-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻1800/守1000）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果把这张卡特殊召唤的回合，自己场上的「机壳」魔法·陷阱卡不会被效果破坏。
-- ②：这张卡的效果特殊召唤的这张卡在「隐藏的机壳」怪兽上级召唤的场合，可以作为3只的数量解放。
function c20447641.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻1800/守1000）在怪兽区域特殊召唤（不当作陷阱卡使用）。
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
-- 检查是否满足特殊召唤的条件，包括场地空位和是否可以特殊召唤该怪兽。
function c20447641.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20447641,0xaa,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置连锁处理中将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果，将此卡作为效果怪兽特殊召唤到场上。
function c20447641.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在场上且可以特殊召唤。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,20447641,0xaa,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		-- 尝试将此卡特殊召唤到场上。
		if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
			c:RegisterFlagEffect(20447641,RESET_EVENT+RESETS_STANDARD,0,1)
			-- 为特殊召唤的此卡注册一个永续效果，使其在该回合不会被效果破坏。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetTargetRange(LOCATION_ONFIELD,0)
			e2:SetTarget(c20447641.indtg)
			e2:SetValue(1)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将效果注册到场上。
			Duel.RegisterEffect(e2,tp)
		end
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 定义效果的适用对象，即「机壳」魔法·陷阱卡。
function c20447641.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xaa)
end
-- 定义用于判断是否可以作为解放的「机壳的冻结」卡。
function c20447641.ttfilter(c)
	return c:GetOriginalCode()==20447641 and c:IsReleasable(REASON_SUMMON) and c:GetFlagEffect(20447641)~=0
end
-- 判断是否满足上级召唤的条件，包括解放数量和场上是否有符合条件的卡。
function c20447641.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断上级召唤所需解放的数量是否不超过3只。
	return minc<=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查场上是否存在符合条件的「机壳的冻结」卡。
		and Duel.IsExistingMatchingCard(c20447641.ttfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断是否为「隐藏的机壳」系列的卡。
function c20447641.tttg(e,c)
	return c:IsSetCard(0x10aa)
end
-- 处理上级召唤时的解放操作，选择并解放符合条件的卡。
function c20447641.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择符合条件的「机壳的冻结」卡作为解放对象。
	local g=Duel.SelectMatchingCard(tp,c20447641.ttfilter,tp,LOCATION_MZONE,0,1,1,nil)
	c:SetMaterial(g)
	-- 将选中的卡进行解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
