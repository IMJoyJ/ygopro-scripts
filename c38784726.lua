--転生炎獣の降臨
-- 效果：
-- 「转生炎兽」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「转生炎兽」仪式怪兽仪式召唤。自己场上有炎属性连接怪兽存在的场合，自己墓地的「转生炎兽」怪兽也能作为解放的代替而回到卡组。
-- ②：这张卡被对方的效果破坏的场合才能发动。从手卡把1只「转生炎兽 翠玉鹰」无视召唤条件特殊召唤。
function c38784726.initial_effect(c)
	-- 注册此卡为「转生炎兽」系列卡片
	aux.AddCodeList(c,16313112)
	-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「转生炎兽」仪式怪兽仪式召唤。自己场上有炎属性连接怪兽存在的场合，自己墓地的「转生炎兽」怪兽也能作为解放的代替而回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38784726.target)
	e1:SetOperation(c38784726.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方的效果破坏的场合才能发动。从手卡把1只「转生炎兽 翠玉鹰」无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c38784726.spcon)
	e2:SetTarget(c38784726.sptg)
	e2:SetOperation(c38784726.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选「转生炎兽」系列怪兽
function c38784726.filter(c,e,tp)
	return c:IsSetCard(0x119)
end
-- 过滤函数，用于筛选可送回卡组的「转生炎兽」系列怪兽
function c38784726.mfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x119) and c:IsAbleToDeck()
end
-- 过滤函数，用于筛选场上的炎属性连接怪兽
function c38784726.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果发动时的处理函数，检查是否满足仪式召唤条件
function c38784726.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式召唤素材组（手牌和场上的怪兽）
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=nil
		-- 检查自己场上是否存在炎属性连接怪兽
		if Duel.IsExistingMatchingCard(c38784726.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 获取玩家墓地中的「转生炎兽」系列怪兽组
			mg2=Duel.GetMatchingGroup(c38784726.mfilter,tp,LOCATION_GRAVE,0,nil)
		end
		-- 检查是否存在满足条件的「转生炎兽」仪式怪兽可被仪式召唤
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c38784726.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示将要将墓地中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
-- 效果发动时的处理函数，执行仪式召唤的具体流程
function c38784726.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用的仪式召唤素材组（手牌和场上的怪兽）
	local mg=Duel.GetRitualMaterial(tp)
	local mg2=nil
	-- 检查自己场上是否存在炎属性连接怪兽
	if Duel.IsExistingMatchingCard(c38784726.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 获取玩家墓地中的「转生炎兽」系列怪兽组
		mg2=Duel.GetMatchingGroup(c38784726.mfilter,tp,LOCATION_GRAVE,0,nil)
	end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足仪式召唤条件的「转生炎兽」仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c38784726.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if mg2 then
			mg:Merge(mg2)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的仪式召唤检查函数
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从可用素材中选择满足等级要求的怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除额外的仪式召唤检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		mat:Sub(mat2)
		-- 解放选中的仪式召唤素材
		Duel.ReleaseRitualMaterial(mat)
		-- 将墓地中的仪式召唤素材送回卡组
		Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选中的仪式怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 判断此卡是否被对方效果破坏且自己控制过此卡
function c38784726.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 过滤函数，用于筛选「转生炎兽 翠玉鹰」
function c38784726.spfilter(c,e,tp)
	return c:IsCode(16313112) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的处理函数，检查是否满足特殊召唤条件
function c38784726.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在「转生炎兽 翠玉鹰」
		and Duel.IsExistingMatchingCard(c38784726.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，执行特殊召唤的具体流程
function c38784726.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的「转生炎兽 翠玉鹰」
	local g=Duel.SelectMatchingCard(tp,c38784726.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「转生炎兽 翠玉鹰」特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
