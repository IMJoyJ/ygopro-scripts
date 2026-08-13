--凶導の福音
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止的自己的手卡·场上的怪兽解放或者和仪式召唤的怪兽相同等级的1只怪兽从额外卡组送去墓地，从手卡把1只「教导」仪式怪兽仪式召唤。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c31002402.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：等级合计直到变成和仪式召唤的怪兽相同为止的自己的手卡·场上的怪兽解放或者和仪式召唤的怪兽相同等级的1只怪兽从额外卡组送去墓地，从手卡把1只「教导」仪式怪兽仪式召唤。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31002402+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31002402.target)
	e1:SetOperation(c31002402.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断怪兽卡是否属于「教导」字段（setname 0x145）。
function c31002402.filter(c,e,tp)
	return c:IsSetCard(0x145)
end
-- 筛选额外卡组中可作为仪式召唤素材送墓的怪兽：等级大于0、是怪兽且能够被送去墓地。
function c31002402.mfilter(c)
	return c:GetLevel()>0 and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 额外卡组怪兽作为仪式召唤素材的额外条件：自己主要怪兽区有空位，且该卡是仪式怪兽（type含0x81）、属于「教导」字段、并且可以被仪式召唤特殊召唤。
function c31002402.rfilter2(c,e,tp,m1)
	-- 若自己主要怪兽区没有空位，则无法将额外卡组的怪兽作为仪式召唤素材，返回false。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x145)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	end
	return mg:IsExists(Card.IsLevel,1,nil,c:GetLevel())
end
-- 发动合法性检查：在手牌中确认是否存在可以使用其中一种素材方式仪式召唤的「教导」仪式怪兽，并设置效果处理时特殊召唤的操作信息。
function c31002402.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的通常仪式素材集合，包括手牌·场上的怪兽以及墓地的仪式魔人等。
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取额外卡组中可以作为仪式素材送去墓地的怪兽集合（等级>0、怪兽、可送墓）。
		local mg2=Duel.GetMatchingGroup(c31002402.mfilter,tp,LOCATION_EXTRA,0,nil)
		-- 检查手牌中是否存在能用“从额外卡组把1只相同等级怪兽送去墓地”作为素材来仪式召唤的「教导」仪式怪兽。
		return Duel.IsExistingMatchingCard(c31002402.rfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,mg2)
			-- 检查手牌中是否存在能用通常仪式召唤方式（解放手牌·场上怪兽，等级合计等于目标怪兽等级）来仪式召唤的「教导」仪式怪兽。
			or Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c31002402.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	end
	-- 设置本连锁的操作信息：本次效果包含从手卡进行1只仪式怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择要仪式召唤的「教导」仪式怪兽，根据情况选择解放素材或额外卡组送墓素材，进行仪式召唤，并在发动后适用额外卡组特殊召唤自肃。
function c31002402.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	-- 获取玩家可用的通常仪式素材集合。
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取额外卡组中可作为“与仪式召唤怪兽相同等级的1只怪兽”送去墓地的候选集合。
	local mg2=Duel.GetMatchingGroup(c31002402.mfilter,tp,LOCATION_EXTRA,0,nil)
	-- 遍历手牌，筛选出可通过通常仪式召唤方式（解放手牌·场上怪兽使等级合计等于该怪兽等级）特殊召唤的「教导」仪式怪兽。
	local g1=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c31002402.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	-- 遍历手牌，筛选出可通过从额外卡组送墓1只相同等级怪兽的方式仪式召唤的「教导」仪式怪兽。
	local g2=Duel.GetMatchingGroup(c31002402.rfilter2,tp,LOCATION_HAND,0,nil,e,tp,mg2)
	local g=g1+g2
	-- 提示玩家选择要特殊召唤的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 若选择的怪兽可用通常解放方式且也可用额外卡组送墓方式时，询问玩家是否选择“把怪兽从额外卡组送去墓地作为素材”；若选择是则走送墓分支，否则走解放分支。
		if g1:IsContains(tc) and (not g2:IsContains(tc) or not Duel.SelectYesNo(tp,aux.Stringid(31002402,0))) then  --"是否把怪兽从额外卡组送去墓地作为素材？"
			-- 提示玩家选择要解放的仪式素材。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			-- 设置辅助检查闭包，确保玩家选择的素材等级合计恰好等于目标仪式怪兽的等级。
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
			-- 从可选素材中选出等级合计恰好等于仪式怪兽等级的素材组；若选择不合法或取消，则跳回重新选择。
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			-- 清除辅助检查闭包，避免影响后续其他仪式召唤的处理。
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 将选定的仪式素材解放（墓地的仪式魔人等除外），完成仪式召唤的素材解放。
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 提示玩家选择要送去墓地的额外卡组怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local matc=mg2:Filter(Card.IsLevel,nil,tc:GetLevel()):SelectUnselect(nil,tp,false,true,1,1)
			if not matc then goto cancel end
			local mat=Group.FromCards(matc)
			tc:SetMaterial(mat)
			-- 将选择的1只与仪式怪兽相同等级的额外卡组怪兽送去墓地，作为仪式召唤素材。
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理，使后续的特殊召唤与之前的素材处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 把选择的「教导」仪式怪兽以表侧表示进行仪式召唤（SUMMON_TYPE_RITUAL），不检查苏生限制。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c31002402.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 给当前玩家注册一个永续效果：直到回合结束时，自己不能从额外卡组把怪兽特殊召唤。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃限制的判定条件：只要怪兽位于额外卡组，就不能被特殊召唤。
function c31002402.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
