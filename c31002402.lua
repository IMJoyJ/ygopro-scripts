--凶導の福音
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止的自己的手卡·场上的怪兽解放或者和仪式召唤的怪兽相同等级的1只怪兽从额外卡组送去墓地，从手卡把1只「教导」仪式怪兽仪式召唤。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c31002402.initial_effect(c)
	-- 创建效果，设置为魔法卡发动，自由连锁，发动次数限制为1次，目标函数为c31002402.target，发动效果为c31002402.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31002402+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31002402.target)
	e1:SetOperation(c31002402.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选「教导」卡组的怪兽
function c31002402.filter(c,e,tp)
	return c:IsSetCard(0x145)
end
-- 过滤函数，用于筛选等级大于0的怪兽卡并能送入墓地
function c31002402.mfilter(c)
	return c:GetLevel()>0 and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤函数，用于筛选可作为仪式召唤素材的「教导」仪式怪兽
function c31002402.rfilter2(c,e,tp,m1)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x145)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	end
	return mg:IsExists(Card.IsLevel,1,nil,c:GetLevel())
end
-- 目标函数，检查是否存在满足条件的「教导」仪式怪兽用于仪式召唤
function c31002402.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式召唤素材组（手牌、场上可解放的怪兽）
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取玩家额外卡组中满足条件的怪兽组（等级大于0且为怪兽卡）
		local mg2=Duel.GetMatchingGroup(c31002402.mfilter,tp,LOCATION_EXTRA,0,nil)
		-- 检查是否存在满足条件的「教导」仪式怪兽，使用rfilter2函数进行筛选
		return Duel.IsExistingMatchingCard(c31002402.rfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,mg2)
			-- 检查是否存在满足条件的「教导」仪式怪兽，使用aux.RitualUltimateFilter函数进行筛选
			or Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c31002402.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 发动函数，处理仪式召唤的具体逻辑
function c31002402.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	-- 获取玩家可用的仪式召唤素材组（手牌、场上可解放的怪兽）
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取玩家额外卡组中满足条件的怪兽组（等级大于0且为怪兽卡）
	local mg2=Duel.GetMatchingGroup(c31002402.mfilter,tp,LOCATION_EXTRA,0,nil)
	-- 获取满足条件的「教导」仪式怪兽组，使用aux.RitualUltimateFilter函数进行筛选
	local g1=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c31002402.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	-- 获取满足条件的「教导」仪式怪兽组，使用rfilter2函数进行筛选
	local g2=Duel.GetMatchingGroup(c31002402.rfilter2,tp,LOCATION_HAND,0,nil,e,tp,mg2)
	local g=g1+g2
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 判断选择的怪兽是否属于g1组，若属于则询问是否从额外卡组送怪兽入墓地作为素材
		if g1:IsContains(tc) and (not g2:IsContains(tc) or not Duel.SelectYesNo(tp,aux.Stringid(31002402,0))) then  --"是否把怪兽从额外卡组送去墓地作为素材？"
			-- 提示玩家选择要解放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			-- 设置额外的仪式召唤检查函数
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
			-- 从可用素材中选择满足条件的素材组
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			-- 清除额外的仪式召唤检查函数
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 解放仪式召唤所用的素材
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local matc=mg2:Filter(Card.IsLevel,nil,tc:GetLevel()):SelectUnselect(nil,tp,false,true,1,1)
			if not matc then goto cancel end
			local mat=Group.FromCards(matc)
			tc:SetMaterial(mat)
			-- 将指定卡送去墓地，原因包括效果、素材、仪式
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 将选择的仪式怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 创建效果，使玩家在本回合不能从额外卡组特殊召唤怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c31002402.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制函数，判断目标怪兽是否在额外卡组
function c31002402.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
