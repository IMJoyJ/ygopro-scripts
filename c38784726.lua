--転生炎獣の降臨
-- 效果：
-- 「转生炎兽」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「转生炎兽」仪式怪兽仪式召唤。自己场上有炎属性连接怪兽存在的场合，自己墓地的「转生炎兽」怪兽也能作为解放的代替而回到卡组。
-- ②：这张卡被对方的效果破坏的场合才能发动。从手卡把1只「转生炎兽 翠玉鹰」无视召唤条件特殊召唤。
function c38784726.initial_effect(c)
	-- 在卡片c上登记卡号16313112（转生炎兽 翠玉鹰），用于关联记载卡名及后续检索/触发处理。
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
-- 定义仪式怪兽选择过滤条件：选择手卡中卡名属于「转生炎兽」字段（0x119）的怪兽作为仪式召唤候选。
function c38784726.filter(c,e,tp)
	return c:IsSetCard(0x119)
end
-- 定义墓地代替素材过滤条件：必须是「转生炎兽」怪兽、持有等级且能够返回卡组，才可作为解放的代替回卡组。
function c38784726.mfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x119) and c:IsAbleToDeck()
end
-- 定义场上条件判断：存在表侧表示的炎属性连接怪兽时，才允许使用墓地的「转生炎兽」怪兽代替解放。
function c38784726.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 发动前检查：获取场上/手卡可用仪式素材及墓地追加素材，确认手卡中是否存在等级合计可满足要求（可大于等于目标等级）的「转生炎兽」仪式怪兽，并预置特殊召唤与回卡组的操作信息。
function c38784726.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家tp当前可用的仪式召唤素材组（手牌、场上可解放怪兽及墓地仪式魔人等）。
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=nil
		-- 判断自己场上是否存在表侧表示的炎属性连接怪兽，以决定是否追加墓地素材。
		if Duel.IsExistingMatchingCard(c38784726.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 若场上存在炎属性连接怪兽，则取得自己墓地中满足条件的「转生炎兽」怪兽作为追加素材组。
			mg2=Duel.GetMatchingGroup(c38784726.mfilter,tp,LOCATION_GRAVE,0,nil)
		end
		-- 通过辅助过滤器检查手卡中是否存在能进行仪式召唤的「转生炎兽」仪式怪兽，且可用当前素材组达成等级要求。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c38784726.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	end
	-- 设置操作信息：本次连锁拟从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本次连锁可能涉及墓地的卡返回卡组（数量在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
-- 仪式召唤的处理流程：重新取得素材，选择手卡仪式怪兽，选择合法素材组合，解放/回卡组素材，最后进行仪式召唤并完成仪式手续。
function c38784726.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 效果处理时重新获取玩家tp的可用仪式素材，确保素材当前仍然合法。
	local mg=Duel.GetRitualMaterial(tp)
	local mg2=nil
	-- 处理时再次确认场上是否存在炎属性连接怪兽，以确保使用墓地代替素材的条件仍成立。
	if Duel.IsExistingMatchingCard(c38784726.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 处理时获取符合条件的墓地「转生炎兽」怪兽作为追加素材。
		mg2=Duel.GetMatchingGroup(c38784726.mfilter,tp,LOCATION_GRAVE,0,nil)
	end
	-- 弹出提示，要求玩家选择要特殊召唤的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只「转生炎兽」仪式怪兽，且该怪兽能够通过仪式召唤的素材检查。
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
		-- 弹出提示，要求玩家选择要解放的仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式素材选择的额外校验规则，要求所选素材的等级合计大于等于目标仪式怪兽的等级。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从可用素材组中选择一组合法的仪式素材，使其等级和满足「大于等于目标等级」的要求。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除临时设置的额外校验规则，避免影响后续其他选择。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		mat:Sub(mat2)
		-- 解放选中的手牌/场上仪式素材，用于仪式召唤。
		Duel.ReleaseRitualMaterial(mat)
		-- 将选中的墓地素材以效果原因、仪式素材原因送回持有者卡组并洗牌，作为解放的代替。
		Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果链，使接下来的仪式召唤视为另一次效果处理，避免错过时点。
		Duel.BreakEffect()
		-- 以仪式召唤形式将目标怪兽表侧表示特殊召唤到己方场上，无视苏生限制并完成仪式召唤手续。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- ②的发动条件：这张卡被对方的效果破坏，且破坏前控制者为己方时才能发动。
function c38784726.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 特殊召唤对象过滤：手卡中的「转生炎兽 翠玉鹰」（卡号16313112），且可以被无视召唤条件特殊召唤。
function c38784726.spfilter(c,e,tp)
	return c:IsCode(16313112) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②的发动检查：自己怪兽区域有空位，且手卡中存在符合条件的翠玉鹰。
function c38784726.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张符合条件的「转生炎兽 翠玉鹰」。
		and Duel.IsExistingMatchingCard(c38784726.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁拟从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②的处理：若怪兽区域仍有空格，选择手卡中的翠玉鹰并无视召唤条件特殊召唤。
function c38784726.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认怪兽区域仍有空格，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张符合条件的「转生炎兽 翠玉鹰」。
	local g=Duel.SelectMatchingCard(tp,c38784726.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的翠玉鹰无视召唤条件表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
