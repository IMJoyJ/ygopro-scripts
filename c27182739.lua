--斬機シグマ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，额外怪兽区域没有自己怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
-- ②：把自己场上的这张卡作为「斩机」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c27182739.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，额外怪兽区域没有自己怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,27182739)
	e1:SetCondition(c27182739.spcon)
	e1:SetTarget(c27182739.sptg)
	e1:SetOperation(c27182739.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上的这张卡作为「斩机」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(c27182739.tnval)
	c:RegisterEffect(e2)
end
-- 该过滤函数用于判断一张卡是否位于额外怪兽区域：场上序列号>=5的怪兽区域即为额外怪兽区（5、6号区域），用于检测额外怪兽区域是否有自己怪兽存在。
function c27182739.cfilter(c)
	return c:GetSequence()>=5
end
-- 效果①的发动条件：我方场上不存在位于额外怪兽区域的自己怪兽（即额外怪兽区域没有自己怪兽存在的场合才能发动）。
function c27182739.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若不存在满足条件的卡（即自己额外怪兽区域没有怪兽），则发动条件成立，返回 true。
	return not Duel.IsExistingMatchingCard(c27182739.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动时的目标处理：先检查自己主要怪兽区是否有空位，且这张卡能否被特殊召唤；满足条件后才可发动并登记操作信息。
function c27182739.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）阶段，确认自己主要怪兽区域存在可用的空格，以保证这张卡可以特殊召唤到主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的特召操作信息：效果处理时将把这张「斩机 西格马」特殊召唤；因为对象确定，故对象指定为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的最终处理：这张卡特殊召唤到己方主要怪兽区；若成功，则给它附加‘离场时除外’的永续效果，并给予己方‘直到回合结束时只能从额外卡组特殊召唤电子界族怪兽’的自肃限制。
function c27182739.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关联（未被无效/离场重置），并且它成功以表侧表示特殊召唤到自己场上，则继续执行后续的离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。②：把自己场上的这张卡作为「斩机」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c27182739.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将此自肃效果注册给发动者tp：直到回合结束时，其不能从额外卡组特殊召唤非电子界族怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的过滤对象：从额外卡组特殊召唤的怪兽中，若不是电子界族，则禁止特殊召唤；即只允许从额外卡组特殊召唤电子界族怪兽。
function c27182739.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的判定：当自己场上的这张卡作为同调素材时，若同调召唤的怪兽的控制者为自己且其卡名属于「斩机」字段，则这张卡在同调素材使用上可以当作调整以外的怪兽。
function c27182739.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsSetCard(0x132)
end
