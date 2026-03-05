--分かつ烙印
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只融合怪兽解放，以自己或对方的墓地·除外状态的除融合怪兽外的2只怪兽为对象才能发动。那些怪兽在双方场上各1只特殊召唤。把需以「阿不思的落胤」为融合素材的融合怪兽解放来把这张卡发动的场合，可以作为代替把作为对象的2只怪兽在自己场上守备表示特殊召唤。
function c1041278.initial_effect(c)
	-- 为卡片注册「阿不思的落胤」作为融合素材的记述
	aux.AddCodeList(c,68468459)
	-- ①：把自己场上1只融合怪兽解放，以自己或对方的墓地·除外状态的除融合怪兽外的2只怪兽为对象才能发动。那些怪兽在双方场上各1只特殊召唤。把需以「阿不思的落胤」为融合素材的融合怪兽解放来把这张卡发动的场合，可以作为代替把作为对象的2只怪兽在自己场上守备表示特殊召唤。
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
-- 定义用于检查解放条件的融合怪兽过滤器函数
function c1041278.rfilter1(c,tp)
	-- 返回满足条件的融合怪兽：控制者为tp或表侧表示，且自身场上有可用怪兽区
	return c:IsType(TYPE_FUSION) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义用于检查特殊召唤条件的融合怪兽过滤器函数
function c1041278.rfilter2(c,tp)
	-- 返回满足条件的融合怪兽：控制者为tp或表侧表示，且为以「阿不思的落胤」为融合素材的融合怪兽
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and (c:IsControler(tp) or c:IsFaceup())
		-- 且自身场上有至少两个可用怪兽区
		and Duel.GetMZoneCount(tp,c)>1
end
-- 定义用于检查目标怪兽是否可特殊召唤的过滤器函数
function c1041278.spfilter0(c,e,tp)
	return not c:IsType(TYPE_FUSION) and c:IsFaceupEx() and c:IsCanBeEffectTarget(e)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 定义用于检查目标怪兽是否可特殊召唤到自己场上的过滤器函数
function c1041278.spfilter1(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and g:IsExists(c1041278.spfilter2,1,c,e,tp)
end
-- 定义用于检查目标怪兽是否可特殊召唤到对方场上的过滤器函数
function c1041278.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 定义用于检查目标怪兽是否可守备表示特殊召唤的过滤器函数
function c1041278.spfilter3(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义发动此卡的费用处理函数
function c1041278.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的墓地或除外区怪兽组
	local g=Duel.GetMatchingGroup(c1041278.spfilter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp)
	-- 检查玩家场上是否存在满足rfilter1条件的可解放融合怪兽
	local b1=Duel.CheckReleaseGroup(tp,c1041278.rfilter1,1,nil,tp)
		-- 检查对方场上是否有可用怪兽区
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
	-- 检查玩家场上是否存在满足rfilter2条件的可解放融合怪兽
	local b2=Duel.CheckReleaseGroup(tp,c1041278.rfilter2,1,nil,tp)
		and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local rfilter=c1041278.rfilter1
	if b2 and not b1 then
		rfilter=c1041278.rfilter2
	end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 选择满足条件的1张可解放融合怪兽
	local rg=Duel.SelectReleaseGroup(tp,rfilter,1,1,nil,tp)
	local rc=rg:GetFirst()
	e:SetLabelObject(rc)
	-- 将选中的融合怪兽解放作为发动费用
	Duel.Release(rg,REASON_COST)
end
-- 定义用于检查目标怪兽组是否满足特殊召唤条件的函数
function c1041278.gcheck(g,e,tp,b1,b2)
	return b1 and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
		or b2 and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
end
-- 定义发动此卡的目标选择处理函数
function c1041278.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家自己场上的可用怪兽区数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上的可用怪兽区数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	-- 获取满足条件的墓地或除外区怪兽组
	local g=Duel.GetMatchingGroup(c1041278.spfilter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp)
	local b1=ft1>0 and ft2>0
		and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and (b1 or e:IsCostChecked()) end
	-- 判断是否为以「阿不思的落胤」为融合素材的融合怪兽
	local check=e:IsCostChecked() and aux.IsMaterialListCode(e:GetLabelObject(),68468459)
	e:SetLabel(check and 1 or 0)
	local b2=check and ft1>1
		and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,c1041278.gcheck,false,2,2,e,tp,b1,b2)
	-- 设置当前连锁的目标怪兽组
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end
-- 定义发动此卡的效果处理函数
function c1041278.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取玩家自己场上的可用怪兽区数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上的可用怪兽区数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if ft1<=0 and ft2<=0 then return end
	-- 获取当前连锁中涉及的目标怪兽组
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 then
		local b1=ft1>0 and ft2>0
			and g:IsExists(c1041278.spfilter1,1,nil,e,tp,g)
		local b2=e:GetLabel()~=0 and ft1>1
			and g:IsExists(c1041278.spfilter3,2,nil,e,tp)
		-- 若满足b2条件且b1不满足或玩家选择守备表示特殊召唤，则执行守备表示特殊召唤
		if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(1041278,0))) then  --"是否把2只怪兽在自己场上守备表示特殊召唤？"
			-- 将目标怪兽组以守备表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		elseif b1 then
			-- 提示玩家选择要特殊召唤到自己场上的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1041278,1))  --"请选择要特殊召唤到自己场上的怪兽"
			local sg=g:FilterSelect(tp,c1041278.spfilter1,1,1,nil,e,tp,g)
			if #sg==0 then return end
			-- 将选中的怪兽以正面表示特殊召唤到自己场上
			Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
			-- 将剩余的怪兽以正面表示特殊召唤到对方场上
			Duel.SpecialSummonStep((g-sg):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
end
