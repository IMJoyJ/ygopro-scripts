--No.93 希望皇ホープ・カイザー
-- 效果：
-- 持有超量素材的相同阶级的「No.」超量怪兽×2只以上
-- ①：1回合1次，自己主要阶段才能发动。把最多有这张卡的超量素材种类数量的9阶以下而攻击力3000以下的「No.」怪兽从额外卡组效果无效特殊召唤（相同阶级最多1只）。那之后，这张卡1个超量素材取除。这个回合，对方受到的战斗伤害变成一半，自己不能把怪兽特殊召唤。
-- ②：只要自己场上有其他的「No.」超量怪兽存在，这张卡不会被战斗·效果破坏。
function c23187256.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加超量召唤手续：使用2只以上（最多99只）持有超量素材的「No.」超量怪兽作为素材，且这些素材的阶级必须相同（由xyzcheck保证），对应召唤条件『持有超量素材的相同阶级的「No.」超量怪兽×2只以上』。
	aux.AddXyzProcedureLevelFree(c,c23187256.mfilter,c23187256.xyzcheck,2,99)
	-- ①：1回合1次，自己主要阶段才能发动。把最多有这张卡的超量素材种类数量的9阶以下而攻击力3000以下的「No.」怪兽从额外卡组效果无效特殊召唤（相同阶级最多1只）。那之后，这张卡1个超量素材取除。这个回合，对方受到的战斗伤害变成一半，自己不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23187256,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c23187256.target)
	e2:SetOperation(c23187256.operation)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有其他的「No.」超量怪兽存在，这张卡不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(c23187256.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
-- 将该卡登记为「No.93」，使卡名中的『No.』字段相关效果能够正确识别此卡。
aux.xyz_number[23187256]=93
-- 定义超量召唤素材的筛选条件：素材怪兽必须是超量类型、持有『No.』字段，并且自身拥有超量素材（作为素材的怪兽必须也是超量怪兽且带有超量素材）。
function c23187256.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and c:IsSetCard(0x48) and c:GetOverlayCount()>0
end
-- 定义素材组的追加限制：所有素材怪兽的阶级（Rank）必须相同（通过种类数是否为1判断），对应『相同阶级的「No.」超量怪兽』。
function c23187256.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 定义效果处理时可选特殊召唤对象的筛选条件：必须是『No.』怪兽、阶级9以下、攻击力3000以下、且当前能够被特殊召唤（满足苏生限制及召唤条件）。
function c23187256.filter(c,e,tp)
	return c:IsRankBelow(9) and c:IsAttackBelow(3000) and c:IsSetCard(0x48)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标的合法性检查：这张卡持有超量素材、有可用的额外卡组怪兽特殊召唤区域、且额外卡组存在至少1只符合条件的『No.』怪兽，满足才可发动。
function c23187256.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查（chk==0）：这张卡（效果持有者）至少有1个超量素材，且当前有可供额外卡组怪兽特殊召唤的空余区域（额外怪兽区空格）。
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0
		-- 发动时检查（chk==0续）：额外卡组中存在至少1张满足filter条件的『No.』怪兽。两项条件均满足时效果才能发动。
		and Duel.IsExistingMatchingCard(c23187256.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果类别为特殊召唤，预计从额外卡组特殊召唤1只怪兽。该信息供其他卡片的发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义辅助过滤器：判断怪兽的阶级是否为指定的rank值（本脚本中未直接调用，用于按阶级筛选的通用逻辑）。
function c23187256.gfilter(c,rank)
	return c:IsRank(rank)
end
-- 效果处理操作：计算可特召数量上限，从额外卡组选出符合条件的『No.』怪兽（相同阶级最多1只）效果无效化并特殊召唤，随后取除这张卡1个超量素材，并设置本回合对方战斗伤害减半、自己不能特殊召唤的约束。
function c23187256.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前可以从额外卡组特殊召唤怪兽的空余区域数量，作为本次可特殊召唤数量上限的基准。
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检测『召唤之门』是否适用：若该效果生效，则读取其记录的当前玩家本回合额外卡组特殊召唤剩余次数限制，用于进一步限制本次特召数量。
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	local c=e:GetHandler()
	-- 从己方额外卡组筛选出所有满足filter条件的『No.』怪兽作为候选组g1。
	local g1=Duel.GetMatchingGroup(c23187256.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local ct=c:GetOverlayGroup():GetClassCount(Card.GetCode)
	if ct>ft then ct=ft end
	if g1:GetCount()>0 and ct>0 then
		-- 向操作玩家显示选择提示：请选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置额外的选卡校验函数为aux.drkcheck，使玩家选择的怪兽阶级必须互不相同，从而满足『相同阶级最多1只』的限制。
		aux.GCheckAdditional=aux.drkcheck
		-- 让玩家从候选组中任意选择1到ct只怪兽（ct为可特召数量上限），并自动应用阶级互不相同的限制，返回选中的组g2。
		local g2=g1:SelectSubGroup(tp,aux.TRUE,false,1,ct)
		-- 清除已设置的额外选卡校验函数，避免影响后续其他选择操作。
		aux.GCheckAdditional=nil
		-- 遍历选中的每组怪兽，逐只进行特殊召唤和无效化处理。
		for tc in aux.Next(g2) do
			-- 将当前怪兽以表侧表示特殊召唤到己方场上（作为连锁中特殊召唤的一步，暂不实际处理，等待SpecialSummonComplete统一完成）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 给被特殊召唤的怪兽赋予EFFECT_DISABLE，使其效果无效化——对应原文『效果无效特殊召唤』中的『效果无效』部分。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 给被特殊召唤的怪兽赋予EFFECT_DISABLE_EFFECT，使其效果被无效化的状态持续（变里侧后重置），进一步落实『效果无效特殊召唤』。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成所有特殊召唤步骤，正式将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummonComplete()
		-- 中断当前效果处理，使特殊召唤与后续的取除素材、自肃效果生效等处理不同步，避免错过时点（让特殊召唤成功的诱发效果可以正常发动）。
		Duel.BreakEffect()
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
	-- 这个回合，对方受到的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(HALF_DAMAGE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将e3（对方战斗伤害减半的永续效果）注册到当前玩家tp，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
	-- 这个回合，自己不能把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	-- 将e4（己方不能特殊召唤的自肃效果）注册到当前玩家tp，持续到回合结束。
	Duel.RegisterEffect(e4,tp)
end
-- 定义②效果的条件过滤器：对象必须是表侧表示、超量怪兽、且是『No.』怪兽。
function c23187256.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 定义②效果的适用条件：自己场上存在其他满足indfilter的『No.』超量怪兽（不包括自身）。
function c23187256.indcon(e)
	-- 检查自己怪兽区是否存在至少1张其他表侧表示的『No.』超量怪兽；存在则返回true，使这张卡获得抗性。
	return Duel.IsExistingMatchingCard(c23187256.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
