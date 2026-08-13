--転生炎獣ゼブロイドX
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己的「转生炎兽」连接怪兽因对方的效果从场上离开的场合才能发动。从自己墓地选包含这张卡的2只4星「转生炎兽」怪兽效果无效特殊召唤，只用那2只为素材把1只「转生炎兽」怪兽超量召唤。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡的攻击力上升这张卡的超量素材数量×300。
function c44161893.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在墓地存在，自己的「转生炎兽」连接怪兽因对方的效果从场上离开的场合才能发动。从自己墓地选包含这张卡的2只4星「转生炎兽」怪兽效果无效特殊召唤，只用那2只为素材把1只「转生炎兽」怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44161893,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,44161893)
	e1:SetCondition(c44161893.spcon)
	e1:SetTarget(c44161893.sptg)
	e1:SetOperation(c44161893.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这张卡的攻击力上升这张卡的超量素材数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c44161893.efcon)
	e2:SetOperation(c44161893.efop)
	c:RegisterEffect(e2)
end
-- 离场怪兽过滤条件：该怪兽离场前是表侧表示、控制者是自己、离场前场上类型为连接怪兽、卡名属于「转生炎兽」，并且是因为对方的效果（而不是其他原因）从场上离开。
function c44161893.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_LINK~=0
		and c:IsPreviousSetCard(0x119) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 诱发条件：离场怪兽组eg中存在至少1只满足上述cfilter的「转生炎兽」连接怪兽，且eg中不包含作为发动源的这张卡自身。
function c44161893.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44161893.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 特殊召唤候选：从自己墓地筛选等级4且属于「转生炎兽」、能被当前效果特殊召唤的怪兽。
function c44161893.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选组规则：选出的2张素材必须包含这张卡自身，且额外卡组中必须存在能只用这2张卡作为素材进行超量召唤的「转生炎兽」超量怪兽。
function c44161893.fselect(g,tp,c)
	return g:IsContains(c)
		-- 确认额外卡组中存在能仅以当前选出的这2只怪兽为素材进行超量召唤的「转生炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c44161893.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 额外卡组筛选：该额外怪兽属于「转生炎兽」，且能使用给定的这2只怪兽作为素材、以2只素材的数量进行超量召唤。
function c44161893.xyzfilter(c,g)
	return c:IsSetCard(0x119) and c:IsXyzSummonable(g,2,2)
end
-- 发动合法性检查并登记：自己本回合还能特殊召唤2只、场上主要怪兽区还有至少2个空位、这张卡自身能从墓地特殊召唤、能选出包含这张卡的2只4星转生炎兽并找到对应的超量怪兽；满足后登记为从墓地特殊召唤2只怪兽。
function c44161893.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己墓地中所有满足特殊召唤条件的4星「转生炎兽」怪兽，作为后续选择素材的候选集合。
	local g=Duel.GetMatchingGroup(c44161893.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检查自己本回合尚未超过特殊召唤次数限制，确保能够连续特殊召唤2只怪兽。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上主要怪兽区还有至少2个可用空格，以保证2只怪兽可以同时特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(c44161893.fselect,2,2,tp,e:GetHandler()) end
	-- 登记操作信息：本效果涉及从墓地特殊召唤2只怪兽，供后续效果检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 效果处理：重新取得可特殊召唤的墓地素材，选择包含这张卡的2只4星「转生炎兽」怪兽，将它们的怪兽效果无效并以表侧表示特殊召唤，完成特殊召唤后，若那2只仍在场上，则选择1只「转生炎兽」超量怪兽用它们作为素材进行超量召唤。
function c44161893.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 使用王家长眠之谷过滤器取得自己墓地中可特殊召唤的4星「转生炎兽」怪兽，排除因王家长眠之谷而不能从墓地特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c44161893.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c44161893.fselect,false,2,2,tp,e:GetHandler())
	if sg and sg:GetCount()==2 then
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 将第1只选中的怪兽以表侧表示加入这次特殊召唤的处理步骤。
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 将第2只选中的怪兽以表侧表示加入这次特殊召唤的处理步骤。
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		-- 从自己墓地选包含这张卡的2只4星「转生炎兽」怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
		-- 从自己墓地选包含这张卡的2只4星「转生炎兽」怪兽效果无效特殊召唤（使其怪兽效果无效化）。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e3)
		local e4=e3:Clone()
		tc2:RegisterEffect(e4)
		-- 完成连续特殊召唤步骤的提交，使这两只怪兽正式特殊召唤成功。
		Duel.SpecialSummonComplete()
		-- 强制刷新当前场上信息，确保后续对特殊召唤成功怪兽的位置和状态判断准确。
		Duel.AdjustAll()
		if sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
		-- 筛选额外卡组中能用当前这2只怪兽作为素材进行超量召唤的「转生炎兽」超量怪兽。
		local xyzg=Duel.GetMatchingGroup(c44161893.xyzfilter,tp,LOCATION_EXTRA,0,nil,sg)
		if xyzg:GetCount()>0 then
			-- 显示选择提示：请选择要超量召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			-- 将选中的「转生炎兽」超量怪兽用已特殊召唤的2只怪兽作为素材进行超量召唤。
			Duel.XyzSummon(tp,xyz,sg)
		end
	end
end
-- 判定②效果触发条件：这张卡是在作为超量召唤素材时触发。
function c44161893.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 给超量召唤出的怪兽赋予攻击力上升效果（上升值由atkval计算）；若该怪兽不是效果怪兽，则追加效果怪兽类型，使其能够正常获得并适用该效果。
function c44161893.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡的攻击力上升这张卡的超量素材数量×300。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(44161893,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c44161893.atkval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡的攻击力上升这张卡的超量素材数量×300。（同时对非效果怪兽补上效果怪兽类型以便适用该效果。）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 攻击力上升值计算：取持有该效果的怪兽（超量召唤出的那只怪兽）当前持有的超量素材数量，乘以300。
function c44161893.atkval(e,c)
	return e:GetHandler():GetOverlayCount()*300
end
