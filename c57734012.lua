--RUM－七皇の剣
-- 效果：
-- 这个卡名的效果在决斗中只能适用1次。
-- ①：自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1开始时才能发动。从自己的额外卡组·墓地选「混沌No.」怪兽以外的1只「No.101」～「No.107」其中任意种的「No.」怪兽特殊召唤，把持有和那只怪兽相同「No.」数字的1只「混沌No.」怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c57734012.initial_effect(c)
	-- ①：自己抽卡阶段通过把通常抽卡的这张卡持续公开
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c57734012.regcon)
	e1:SetOperation(c57734012.regop)
	c:RegisterEffect(e1)
	-- 那个回合的主要阶段1开始时才能发动。从自己的额外卡组·墓地选「混沌No.」怪兽以外的1只「No.101」～「No.107」其中任意种的「No.」怪兽特殊召唤，把持有和那只怪兽相同「No.」数字的1只「混沌No.」怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c57734012.condition)
	e2:SetCost(c57734012.cost)
	e2:SetTarget(c57734012.target)
	e2:SetOperation(c57734012.activate)
	c:RegisterEffect(e2)
end
-- 通常抽卡公开效果的条件过滤
function c57734012.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查决斗中是否未适用过此效果、当前是否为抽卡阶段、且该卡是否因规则抽卡而加入手卡
	return Duel.GetFlagEffect(tp,57734012)==0 and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 通常抽卡公开效果的处理：询问玩家是否公开此卡
function c57734012.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家是否选择持续公开手牌中的「升阶魔法-七皇之剑」
	if Duel.SelectYesNo(tp,aux.Stringid(57734012,0)) then  --"是否要持续公开「升阶魔法-七皇之剑」？"
		-- 持续公开
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(57734012,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 卡片发动条件过滤
function c57734012.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段1的开始时（玩家尚未进行任何非强制操作）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 发动代价：检查此卡是否已被持续公开（带有对应的Flag标记）
function c57734012.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(57734012)~=0 end
end
-- 过滤满足特殊召唤条件的「No.101」～「No.107」怪兽
function c57734012.filter1(c,e,tp)
	-- 获取该怪兽的「No.」数字
	local no=aux.GetXyzNumber(c)
	-- 检查玩家是否受到额外卡组特殊召唤次数限制效果的影响
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and not c:IsSetCard(0x1048)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not ect or ect>1 or c:IsLocation(LOCATION_GRAVE))
		-- 检查额外卡组是否存在可以重叠特殊召唤的对应「混沌No.」怪兽
		and Duel.IsExistingMatchingCard(c57734012.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no)
end
-- 过滤额外卡组中持有相同「No.」数字且可以重叠召唤的「混沌No.」怪兽
function c57734012.filter2(c,e,tp,mc,no)
	-- 检查怪兽的「No.」数字是否相同、是否为「混沌No.」怪兽，且第一只怪兽能否作为其超量素材
	return aux.GetXyzNumber(c)==no and c:IsSetCard(0x1048) and mc:IsCanBeXyzMaterial(c)
		-- 检查该「混沌No.」怪兽能否以超量召唤的方式特殊召唤，且额外怪兽区域有可用空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 发动准备与合法性检查
function c57734012.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	-- 检查玩家是否受到额外卡组特殊召唤次数限制效果的影响
	local ect=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
		-- 获取受限的剩余召唤次数
		and aux.ExtraDeckSummonCountLimit[tp]
	-- 若怪兽区域有空位，则特殊召唤范围包含墓地
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	-- 若额外怪兽区域有空位且允许召唤次数足够，则特殊召唤范围包含额外卡组
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0 and (ect==nil or ect>1) then loc=loc+LOCATION_EXTRA end
	-- 在发动检查时，确认玩家是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 确认决斗中未适用过此效果，且有可用的特殊召唤来源区域
		and Duel.GetFlagEffect(tp,57734012)==0 and loc~=0
		-- 检查是否存在必须作为超量素材的怪兽限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在至少1只满足条件的「No.101」～「No.107」怪兽
		and Duel.IsExistingMatchingCard(c57734012.filter1,tp,loc,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从墓地或额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果处理：特殊召唤第一只怪兽，并重叠特殊召唤对应的「混沌No.」怪兽
function c57734012.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 防刷，若决斗中已适用过此效果则直接返回
	if Duel.GetFlagEffect(tp,57734012)~=0 then return end
	-- 给玩家注册决斗中已适用过此效果的全局标记
	Duel.RegisterFlagEffect(tp,57734012,0,0,0)
	local loc=0
	-- 检查玩家是否受到额外卡组特殊召唤次数限制效果的影响
	local ect=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
		-- 获取受限的剩余召唤次数
		and aux.ExtraDeckSummonCountLimit[tp]
	-- 若怪兽区域有空位，则特殊召唤范围包含墓地
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	-- 若额外怪兽区域有空位且允许召唤次数足够，则特殊召唤范围包含额外卡组
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0 and (ect==nil or ect>1) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地或额外卡组选择1只满足条件的「No.101」～「No.107」怪兽（受王家长眠之谷影响）
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c57734012.filter1),tp,loc,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	-- 将选中的第一只怪兽表侧表示特殊召唤
	if tc1 and Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查该怪兽是否满足必须作为超量素材的限制条件
		if not aux.MustMaterialCheck(tc1,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		-- 获取已特殊召唤怪兽的「No.」数字
		local no=aux.GetXyzNumber(tc1)
		-- 提示玩家选择要特殊召唤的「混沌No.」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只持有相同「No.」数字的「混沌No.」怪兽
		local g2=Duel.SelectMatchingCard(tp,c57734012.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc1,no)
		local tc2=g2:GetFirst()
		if tc2 then
			-- 中断当前效果处理，使后续的重叠特殊召唤不与前一次特殊召唤同时处理
			Duel.BreakEffect()
			tc2:SetMaterial(g1)
			-- 将第一只怪兽作为超量素材重叠在「混沌No.」怪兽下面
			Duel.Overlay(tc2,g1)
			-- 将该「混沌No.」怪兽当作超量召唤特殊召唤到场上
			Duel.SpecialSummon(tc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			tc2:CompleteProcedure()
		end
	end
end
