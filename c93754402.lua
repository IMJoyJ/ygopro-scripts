--炎舞－「洞明」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只兽战士族仪式怪兽仪式召唤。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「炎星」怪兽为对象才能发动。那只怪兽特殊召唤。
function c93754402.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，以下效果可以适用。●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只兽战士族仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93754402+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c93754402.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「炎星」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93754402,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,93754403)
	e2:SetCondition(c93754402.spcon)
	e2:SetTarget(c93754402.sptg)
	e2:SetOperation(c93754402.spop)
	c:RegisterEffect(e2)
end
-- 过滤兽战士族怪兽
function c93754402.filter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR)
end
-- 卡片发动时的效果处理（仪式召唤）
function c93754402.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用于仪式召唤的素材怪兽组
	local mg=Duel.GetRitualMaterial(tp)
	-- 获取手卡中满足仪式召唤条件的兽战士族仪式怪兽
	local g=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c93754402.filter,e,tp,mg,nil,Card.GetLevel,"Greater")
	-- 若存在可仪式召唤的怪兽，询问玩家是否进行仪式召唤
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(93754402,1)) then  --"是否仪式召唤？"
		-- 提示玩家选择要特殊召唤的仪式怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的仪式素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式召唤素材等级合计需大于或等于目标怪兽等级的附加检查函数
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择满足仪式召唤条件的素材怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 重置附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果，使后续的特殊召唤处理不与解放同时处理
		Duel.BreakEffect()
		-- 将仪式怪兽以仪式召唤的方式表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 检查此卡是否从魔法与陷阱区域的表侧表示状态送去墓地
function c93754402.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤墓地中可以特殊召唤的「炎星」怪兽
function c93754402.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域空位、是否存在合法目标并选择对象）
function c93754402.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93754402.spfilter(chkc,e,tp) end
	-- 检查玩家怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「炎星」怪兽
		and Duel.IsExistingTarget(c93754402.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「炎星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93754402.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（特殊召唤目标怪兽）
function c93754402.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
