--クラスター・ペンデュラム
-- 效果：
-- ①：这张卡召唤成功时才能发动。把最多有对方场上的怪兽数量的「钟摆衍生物」（机械族·地·1星·攻/守0）在自己场上特殊召唤。
function c27450400.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。把最多有对方场上的怪兽数量的「钟摆衍生物」（机械族·地·1星·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27450400,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27450400.sptg)
	e1:SetOperation(c27450400.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的合法条件检查函数（Target）：确认自己主要怪兽区有空位、对方场上有怪兽存在，并且自己能够特殊召唤「钟摆衍生物」。
function c27450400.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区有可用空格，且对方场上有怪兽（作为可特殊召唤数量的依据）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己玩家是否能够特殊召唤「钟摆衍生物」（机械族·地·1星·攻/守0的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27450401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置本次连锁的操作信息：包含衍生物生成的类别，数量暂定1，实际数量在效果处理时确定，因此目标为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次连锁的操作信息：包含特殊召唤的类别，数量暂定1，实际数量在效果处理时确定，因此目标为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理时的操作函数：根据对方场上的怪兽数量和自己的可用怪兽区数量决定特殊召唤token的数量（取较小值）；若「青眼精灵龙」的效果生效中则最多只能特殊召唤1只；随后逐只生成token并特殊召唤，玩家可中途选择停止，最后完成特殊召唤。
function c27450400.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区的可用空格数量，作为本次可特殊召唤token的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上的怪兽数量，作为本次特殊召唤token数量的上限。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 特殊召唤前再次确认自己仍能特殊召唤该衍生物，若不能则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,27450401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	local ctn=true
	while ft>0 and ctn do
		-- 生成一张「钟摆衍生物」(27450401) 的衍生物卡。
		local token=Duel.CreateToken(tp,27450401)
		-- 将生成的衍生物以表侧表示特殊召唤到自己场上（批量特殊召唤的中间步骤，暂不完成召唤）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
		-- 如果已召唤数量达到上限或玩家选择“否”，则停止继续特殊召唤；否则继续询问是否生成下一只。
		if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(27450400,1)) then ctn=false end  --"是否继续特殊召唤「钟摆衍生物」？"
	end
	-- 结束批量特殊召唤处理，将之前通过SpecialSummonStep累积的特殊召唤统一完成。
	Duel.SpecialSummonComplete()
end
