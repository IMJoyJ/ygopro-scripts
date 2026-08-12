--バスター・モード・ゼロ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只同调怪兽解放才能发动。包含那只怪兽卡名的1只「/爆裂体」怪兽当作「爆裂模式」的特殊召唤从手卡特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡·卡组选1张「爆裂模式」在自己的魔法与陷阱区域盖放。这个效果盖放的卡在盖放的回合也能发动。
function c88332693.initial_effect(c)
	-- 注册卡片「爆裂模式」的代码，表示这张卡的效果中记有该卡名。
	aux.AddCodeList(c,80280737)
	-- ①：把自己场上1只同调怪兽解放才能发动。包含那只怪兽卡名的1只「/爆裂体」怪兽当作「爆裂模式」的特殊召唤从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88332693,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,88332693)
	e1:SetCost(c88332693.cost)
	e1:SetTarget(c88332693.target)
	e1:SetOperation(c88332693.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡·卡组选1张「爆裂模式」在自己的魔法与陷阱区域盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88332693,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,88332694)
	-- 将此卡从墓地除外作为发动效果的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c88332693.settg)
	e2:SetOperation(c88332693.setop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价处理函数（标记此效果在发动时需要进行解放操作）。
function c88332693.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤自己场上可以解放的同调怪兽（要求解放后有空余怪兽区域，且手卡有包含其卡名的「/爆裂体」怪兽）。
function c88332693.filter1(c,e,tp)
	-- 检查卡片是否为同调怪兽，且该怪兽离开场后自己场上有可用的怪兽区域。
	return c:IsType(TYPE_SYNCHRO) and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡是否存在至少1只包含该同调怪兽卡名的「/爆裂体」怪兽。
		and Duel.IsExistingMatchingCard(c88332693.filter2,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 过滤手卡中包含指定同调怪兽卡名、且可以当作「爆裂模式」特殊召唤的「/爆裂体」怪兽。
function c88332693.filter2(c,e,tp,tcode)
	return c:IsSetCard(0x104f) and c.assault_name==tcode and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_ASSAULT_MODE,tp,false,true)
end
-- ①号效果的发动准备与目标确认函数（检查并选择要解放的同调怪兽，记录其卡名，并将其解放）。
function c88332693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足解放条件的同调怪兽。
		return Duel.CheckReleaseGroup(tp,c88332693.filter1,1,nil,e,tp)
	end
	-- 玩家选择自己场上1只满足条件的同调怪兽。
	local rg=Duel.SelectReleaseGroup(tp,c88332693.filter1,1,1,nil,e,tp)
	-- 将选中的同调怪兽的卡片密码保存为效果参数，以便在效果处理时使用。
	Duel.SetTargetParam(rg:GetFirst():GetCode())
	-- 将选中的同调怪兽解放。
	Duel.Release(rg,REASON_COST)
	-- 设置连锁信息，表明此效果包含从手卡特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①号效果的实际处理函数（从手卡将包含被解放怪兽卡名的「/爆裂体」怪兽特殊召唤）。
function c88332693.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时保存的被解放同调怪兽的卡片密码。
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只包含被解放怪兽卡名的「/爆裂体」怪兽。
	local tc=Duel.SelectMatchingCard(tp,c88332693.filter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,code):GetFirst()
	-- 若成功选择卡片，则将其当作「爆裂模式」的特殊召唤以表侧表示特殊召唤。
	if tc and Duel.SpecialSummon(tc,SUMMON_VALUE_ASSAULT_MODE,tp,tp,false,true,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
-- 过滤手卡或卡组中可以盖放的「爆裂模式」。
function c88332693.setfilter(c)
	return c:IsCode(80280737) and c:IsSSetable()
end
-- ②号效果的发动准备与目标确认函数（检查手卡或卡组中是否存在可盖放的「爆裂模式」）。
function c88332693.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在至少1张可以盖放的「爆裂模式」。
	if chk==0 then return Duel.IsExistingMatchingCard(c88332693.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
-- ②号效果的实际处理函数（从手卡或卡组盖放1张「爆裂模式」，并赋予其在盖放回合也能发动的效果）。
function c88332693.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从手卡或卡组选择1张「爆裂模式」。
	local tc=Duel.SelectMatchingCard(tp,c88332693.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 若成功选择卡片，则将其在自己的魔法与陷阱区域盖放。
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(88332693,2))  --"适用「爆裂模式零型」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e2)
	end
end
