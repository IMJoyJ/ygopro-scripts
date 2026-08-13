--鏡像のスワンプマン
-- 效果：
-- ①：宣言种族和属性各1个才能把这张卡发动。这张卡变成持有宣言的种族·属性的通常怪兽（4星·攻1800/守1000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
function c50277973.initial_effect(c)
	-- ①：宣言种族和属性各1个才能把这张卡发动。这张卡变成持有宣言的种族·属性的通常怪兽（4星·攻1800/守1000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c50277973.target)
	e1:SetOperation(c50277973.activate)
	c:RegisterEffect(e1)
end
-- 发动时的条件检查和宣言处理：先计算玩家能否以任意种族/属性组合把此卡作为通常怪兽特殊召唤，并记录可选的种族范围；若满足发动条件，再让玩家宣言1个种族和1个属性，将种族存入效果标签、属性存入连锁参数，并设置特殊召唤的操作信息。
function c50277973.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rac=0
		local crac=1
		while bit.band(RACE_ALL,crac)~=0 do
			local catt=1
			for iatt=0,7 do
				-- 检查在当前的种族crac和属性catt组合下，玩家是否可以将此卡作为4星·攻1800/守1000的通常怪兽特殊召唤，用于筛选出可宣言的能力组合。
				if Duel.IsPlayerCanSpecialSummonMonster(tp,50277973,0,TYPES_NORMAL_TRAP_MONSTER,1800,1000,4,crac,catt) then
					rac=rac+crac
					break
				end
				catt=catt*2
			end
			crac=crac*2
		end
		e:SetLabel(rac)
		return e:IsCostChecked()
			-- 判断是否存在至少一个可用的种族组合（rac≠0），且我方主要怪兽区域有空位可以特殊召唤。
			and rac~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 提示玩家接下来需要宣言种族，显示种族选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从之前计算出的可用种族范围e:GetLabel()中宣言1个种族，返回值crac为所宣言的种族。
	local crac=Duel.AnnounceRace(tp,1,e:GetLabel())
	local att=0
	local catt=1
	for iatt=0,7 do
		-- 在玩家宣言完种族后，检查该种族与当前候选属性catt的组合是否允许此卡特殊召唤，用于筛出可宣言的属性范围。
		if Duel.IsPlayerCanSpecialSummonMonster(tp,50277973,0,TYPES_NORMAL_TRAP_MONSTER,1800,1000,4,crac,catt) then
			att=att+catt
		end
		catt=catt*2
	end
	-- 提示玩家接下来需要宣言属性，显示属性选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可用属性范围att中宣言1个属性，返回值catt为所宣言的属性。
	catt=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(crac)
	-- 把宣言的属性值保存到当前连锁的对象参数中，供效果处理阶段读取。
	Duel.SetTargetParam(catt)
	-- 设置本次发动的操作信息：将这张卡本身作为特殊召唤的对象，预定特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：读取已宣言的种族和属性，再次确认玩家仍能以此组合特殊召唤该陷阱怪兽；若能，则给这张卡附加通常怪兽属性（类型为通常怪兽+陷阱，属性为宣言属性，种族为宣言种族，4星·攻1800/守1000），并将其特殊召唤到怪兽区域。
function c50277973.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac=e:GetLabel()
	-- 从连锁信息中取出发动时保存的宣言属性值att。
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 处理前再次检查：若玩家无法以宣言的种族和属性将此卡作为通常怪兽特殊召唤，则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,50277973,0,TYPES_NORMAL_TRAP_MONSTER,1800,1000,4,rac,att) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,att,rac,0,0,0)
	-- 将这张卡以表侧表示形式特殊召唤到玩家场上（不做召唤条件检查，遵守苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
