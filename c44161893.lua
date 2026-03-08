--転生炎獣ゼブロイドX
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己的「转生炎兽」连接怪兽因对方的效果从场上离开的场合才能发动。从自己墓地选包含这张卡的2只4星「转生炎兽」怪兽效果无效特殊召唤，只用那2只为素材把1只「转生炎兽」怪兽超量召唤。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡的攻击力上升这张卡的超量素材数量×300。
function c44161893.initial_effect(c)
	-- ①：这张卡在墓地存在，自己的「转生炎兽」连接怪兽因对方的效果从场上离开的场合才能发动。
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
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c44161893.efcon)
	e2:SetOperation(c44161893.efop)
	c:RegisterEffect(e2)
end
-- 过滤条件：离开场上的怪兽必须是正面表示、是自己的、类型为连接、种族为转生炎兽、是对方效果导致离开、且离开原因必须是效果
function c44161893.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_LINK~=0
		and c:IsPreviousSetCard(0x119) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 条件判断：满足过滤条件的怪兽数量大于等于1，且不包含自己（即不是自己发动的效果导致自己离场）
function c44161893.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44161893.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：等级为4、种族为转生炎兽、可以被特殊召唤
function c44161893.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择条件：所选的2张卡必须包含自己，并且在额外卡组中存在满足超量召唤条件的怪兽
function c44161893.fselect(g,tp,c)
	return g:IsContains(c)
		-- 检测额外卡组中是否存在满足超量召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c44161893.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 过滤条件：种族为转生炎兽、可以使用指定的2张卡作为素材进行超量召唤
function c44161893.xyzfilter(c,g)
	return c:IsSetCard(0x119) and c:IsXyzSummonable(g,2,2)
end
-- 目标设置：检查是否满足特殊召唤2只怪兽的条件，包括玩家可特殊召唤次数、场地空位、自身是否可特殊召唤、以及墓地是否有满足条件的2张卡
function c44161893.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足特殊召唤条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c44161893.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检查玩家是否可以特殊召唤2只怪兽
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(c44161893.fselect,2,2,tp,e:GetHandler()) end
	-- 设置操作信息：准备特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 处理函数：检测是否满足发动条件，获取满足条件的墓地怪兽组，选择2张卡进行特殊召唤，将这2张卡效果无效并特殊召唤，然后进行超量召唤
function c44161893.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 获取满足特殊召唤条件的墓地怪兽组（排除王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c44161893.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c44161893.fselect,false,2,2,tp,e:GetHandler())
	if sg and sg:GetCount()==2 then
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 特殊召唤第一张卡
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 特殊召唤第二张卡
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		-- 使第一张卡效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
		-- 使第一张卡的效果被无效化
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e3)
		local e4=e3:Clone()
		tc2:RegisterEffect(e4)
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
		-- 刷新场上信息
		Duel.AdjustAll()
		if sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
		-- 获取满足超量召唤条件的额外怪兽组
		local xyzg=Duel.GetMatchingGroup(c44161893.xyzfilter,tp,LOCATION_EXTRA,0,nil,sg)
		if xyzg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			-- 使用选定的2张卡进行超量召唤
			Duel.XyzSummon(tp,xyz,sg)
		end
	end
end
-- 条件判断：作为超量素材的怪兽必须是因超量召唤而被加入的
function c44161893.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 处理函数：当此卡作为超量素材时，使对应的超量怪兽攻击力上升其超量素材数量×300
function c44161893.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为超量怪兽添加攻击力上升效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(44161893,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c44161893.atkval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若超量怪兽不具有效果类型，则为其添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 攻击力上升值为超量素材数量×300
function c44161893.atkval(e,c)
	return e:GetHandler():GetOverlayCount()*300
end
