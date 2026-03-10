--鏡像のスワンプマン
-- 效果：
-- ①：宣言种族和属性各1个才能把这张卡发动。这张卡变成持有宣言的种族·属性的通常怪兽（4星·攻1800/守1000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
function c50277973.initial_effect(c)
	-- 效果原文内容：①：宣言种族和属性各1个才能把这张卡发动。这张卡变成持有宣言的种族·属性的通常怪兽（4星·攻1800/守1000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c50277973.target)
	e1:SetOperation(c50277973.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，检查玩家是否可以特殊召唤此卡到怪兽区域。
function c50277973.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rac=0
		local crac=1
		while bit.band(RACE_ALL,crac)~=0 do
			local catt=1
			for iatt=0,7 do
				-- 判断玩家是否可以以指定种族和属性特殊召唤此卡为通常怪兽。
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
			-- 确保玩家场上存在空位且已宣言种族。
			and rac~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 提示玩家选择要宣言的种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从可选种族中宣言一个种族。
	local crac=Duel.AnnounceRace(tp,1,e:GetLabel())
	local att=0
	local catt=1
	for iatt=0,7 do
		-- 判断玩家是否可以以指定种族和属性特殊召唤此卡为通常怪兽。
		if Duel.IsPlayerCanSpecialSummonMonster(tp,50277973,0,TYPES_NORMAL_TRAP_MONSTER,1800,1000,4,crac,catt) then
			att=att+catt
		end
		catt=catt*2
	end
	-- 提示玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可选属性中宣言一个属性。
	catt=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(crac)
	-- 将宣言的属性参数设置为目标参数。
	Duel.SetTargetParam(catt)
	-- 设置当前处理的连锁的操作信息，确定特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果原文内容：①：宣言种族和属性各1个才能把这张卡发动。这张卡变成持有宣言的种族·属性的通常怪兽（4星·攻1800/守1000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
function c50277973.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac=e:GetLabel()
	-- 获取连锁中目标参数，即玩家宣言的属性值。
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 判断玩家是否可以以指定种族和属性特殊召唤此卡为通常怪兽。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,50277973,0,TYPES_NORMAL_TRAP_MONSTER,1800,1000,4,rac,att) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,att,rac,0,0,0)
	-- 将此卡以通常怪兽形式特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
