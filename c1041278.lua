--分かつ烙印
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只融合怪兽解放，以自己或对方的墓地·除外状态的除融合怪兽外的2只怪兽为对象才能发动。那些怪兽在双方场上各1只特殊召唤。把需以「阿不思的落胤」为融合素材的融合怪兽解放来把这张卡发动的场合，可以作为代替把作为对象的2只怪兽在自己场上守备表示特殊召唤。
function c1041278.initial_effect(c)
	-- 在卡片中注册关联卡片：阿不思的落胤
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只融合怪兽解放，以自己或对方的墓地·除外状态的除融合怪兽外的2只怪兽为对象才能发动。那些怪兽在双方场上各1只特殊召唤。把需以「阿不思的落胤」为融合素材的融合怪兽解放来把这张卡发动的场合，可以作为代替把作为对象的2只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,1041278+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c1041278.cost)
	e1:SetTarget(c1041278.target)
	e1:SetOperation(c1041278.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上可作为解放的融合怪兽的条件函数
function c1041278.rfilter1(c,tp)
	-- 检查必须是自己场上的融合怪兽，且将其解放后自己场上能留出至少1个怪兽区域
	return c:IsType(TYPE_FUSION) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤需以「阿不思的落胤」为融合素材且解放后自己场上留出至少2个怪兽区域的融合怪兽的条件函数
function c1041278.rfilter2(c,tp)
	-- 检查必须是需以「阿不思的落胤」为融合素材的融合怪兽，且在自己场上受自己控制
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and (c:IsControler(tp) or c:IsFaceup())
		-- 要求该融合怪兽被解放后自己场上必须留出至少2个空怪兽区域
		and Duel.GetMZoneCount(tp,c)>1
end
-- 过滤作为对象的、自己或对方的墓地或除外状态的除融合怪兽外的怪兽
function c1041278.spfilter0(c,e,tp)
	return not c:IsType(TYPE_FUSION) and c:IsFaceupEx() and c:IsCanBeEffectTarget(e)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 用于判断从怪兽组里能否选出在自己场上特召一只、同时另一只特召到对方场上的组合的条件函数
function c1041278.spfilter1(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and g:IsExists(c1041278.spfilter2,1,c,e,tp)
end
-- 检查怪兽是否能特殊召唤到对方场上
function c1041278.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 检查怪兽是否能以守备表示特殊召唤至自己场上
function c1041278.spfilter3(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的发动Cost：选择自己场上一只融合怪兽解放
function c1041278.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己与对方的墓地、除外区中满足特召条件且非融合怪兽的怪兽组
	local g=Duel.GetMatchingGroup(c1041278.spfilter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp)
	-- 检查自己场上是否有满足条件的普通融合怪兽可供解放
	local b1=Duel.CheckReleaseGroup(tp,c1041278.rfilter1,1,nil,tp)
		-- 要求对方场上也有空怪兽区域以进行双方场上的特殊召唤
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
	-- 检查自己场上是否有满足条件的以「阿不思的落胤」为素材的融合怪兽可供解放
	local b2=Duel.CheckReleaseGroup(tp,c1041278.rfilter2,1,nil,tp)
		and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local rfilter=c1041278.rfilter1
	if b2 and not b1 then
		rfilter=c1041278.rfilter2
	end
	-- 提示玩家选择要解放的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择要解放的1只融合怪兽
	local rg=Duel.SelectReleaseGroup(tp,rfilter,1,1,nil,tp)
	local rc=rg:GetFirst()
	e:SetLabelObject(rc)
	-- 将选中的融合怪兽解放
	Duel.Release(rg,REASON_COST)
end
-- 用于过滤并选中2只特召怪兽组合的辅助检查函数
function c1041278.gcheck(g,e,tp,b1,b2)
	return b1 and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
		or b2 and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
end
-- 效果的发动Target函数：选择自己或对方的墓地·除外状态的除融合怪兽外的2只怪兽作为对象
function c1041278.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上的可用怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上的可用怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	-- 获取自己或对方的墓地或除外区中可以作为对象的非融合怪兽组
	local g=Duel.GetMatchingGroup(c1041278.spfilter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp)
	local b1=ft1>0 and ft2>0
		and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and (b1 or e:IsCostChecked()) end
	-- 检查解放作为Cost的怪兽是否是需以「阿不思的落胤」为融合素材的融合怪兽
	local check=e:IsCostChecked() and aux.IsMaterialListCode(e:GetLabelObject(),68468459)
	e:SetLabel(check and 1 or 0)
	local b2=check and ft1>1
		and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c1041278.gcheck,false,2,2,e,tp,b1,b2)
	-- 设置选择的2只怪兽为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤2只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end
-- 效果的Operation函数：将对象怪兽在双方场上各1只特殊召唤，或者在自己场上守备表示特殊召唤
function c1041278.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取自己场上的空怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上的空怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if ft1<=0 and ft2<=0 then return end
	-- 获取在连锁处理时仍与该连锁相关的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 then
		local b1=ft1>0 and ft2>0
			and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
		local b2=e:GetLabel()~=0 and ft1>1
			and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
		-- 若满足代替特召的条件，则由玩家选择是否将2只对象怪兽全部在自己场上守备表示特殊召唤
		if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(1041278,0))) then  --"是否把2只怪兽在自己场上守备表示特殊召唤？"
			-- 将2只对象怪兽在自己场上守备表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		elseif b1 then
			-- 提示选择要特殊召唤到自己场上的那1只怪兽
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1041278,1))  --"请选择要特殊召唤到自己场上的怪兽"
			local sg=g:FilterSelect(tp,c1041278.spfilter1,1,1,nil,e,tp,g)
			if #sg==0 then return end
			-- 将第1只被选中的怪兽特殊召唤到自己场上
			Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
			-- 将剩下的另1只怪兽特殊召唤到对方场上
			Duel.SpecialSummonStep((g-sg):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
			-- 完成上述2只怪兽的特殊召唤处理
			Duel.SpecialSummonComplete()
		end
	end
end
