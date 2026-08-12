--量子猫
-- 效果：
-- ①：宣言种族和属性各1个才能把这张卡发动。这张卡发动后变成持有宣言的种族·属性的通常怪兽（4星·攻0/守2200）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
function c87772572.initial_effect(c)
	-- ①：宣言种族和属性各1个才能把这张卡发动。这张卡发动后变成持有宣言的种族·属性的通常怪兽（4星·攻0/守2200）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c87772572.target)
	e1:SetOperation(c87772572.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理，进行可行性检查并让玩家宣言种族和属性
function c87772572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rac=0
		local crac=1
		while bit.band(RACE_ALL,crac)~=0 do
			local catt=1
			for iatt=0,7 do
				-- 检查玩家是否能将该卡作为指定种族和属性的陷阱怪兽特殊召唤
				if Duel.IsPlayerCanSpecialSummonMonster(tp,87772572,0,TYPES_NORMAL_TRAP_MONSTER,0,2200,4,crac,catt) then
					rac=rac+crac
					break
				end
				catt=catt*2
			end
			crac=crac*2
		end
		e:SetLabel(rac)
		return e:IsCostChecked()
			-- 检查是否存在可宣言的种族，且怪兽区域有空位
			and rac~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 提示玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从可宣言的种族中选择并宣言1个种族
	local crac=Duel.AnnounceRace(tp,1,e:GetLabel())
	local att=0
	local catt=1
	for iatt=0,7 do
		-- 在已确定宣言种族的情况下，检查哪些属性是可合法特殊召唤的
		if Duel.IsPlayerCanSpecialSummonMonster(tp,87772572,0,TYPES_NORMAL_TRAP_MONSTER,0,2200,4,crac,catt) then
			att=att+catt
		end
		catt=catt*2
	end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可宣言的属性中选择并宣言1个属性
	catt=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(crac)
	-- 将宣言的属性作为目标参数保存，以便在效果处理时获取
	Duel.SetTargetParam(catt)
	-- 设置效果处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 卡片发动后的效果处理，将自身作为指定种族和属性的通常怪兽特殊召唤
function c87772572.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac=e:GetLabel()
	-- 获取发动时宣言并保存的属性
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 检查在效果处理时是否仍能将该卡作为指定种族和属性的怪兽特殊召唤
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,87772572,0,TYPES_NORMAL_TRAP_MONSTER,0,2200,4,rac,att) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,att,rac,0,0,0)
	-- 将这张卡在怪兽区域表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
