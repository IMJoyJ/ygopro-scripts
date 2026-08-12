--シーアーカイバー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，场上的连接怪兽所连接区有怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c53309998.initial_effect(c)
	-- 为卡片注册一个监听送入墓地事件的单次持续效果，用于记录卡片是否已从场上离开并进入墓地的状态
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡在手卡·墓地存在，场上的连接怪兽所连接区有怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53309998,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,53309998)
	e1:SetLabelObject(e0)
	e1:SetCondition(c53309998.spcon)
	e1:SetTarget(c53309998.sptg)
	e1:SetOperation(c53309998.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 用于判断怪兽是否在连接区域中，通过序列号和区域位图进行匹配，并排除特定效果来源的怪兽
function c53309998.cfilter(c,zone,se)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:IsPreviousControler(1) then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0 and (se==nil or c:GetReasonEffect()~=se)
end
-- 条件函数：检查是否有满足条件的怪兽被召唤或特殊召唤，且其所在区域与连接区重叠
function c53309998.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	-- 获取双方玩家的连接区域位图并合并为一个32位整数用于后续判断
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return eg:IsExists(c53309998.cfilter,1,nil,zone,se)
end
-- 目标设置函数：检查是否可以将卡片特殊召唤到场上
function c53309998.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表明此效果会将卡片特殊召唤到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：执行特殊召唤操作，并为特殊召唤的卡片添加离开场上的除外效果
function c53309998.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否仍然在场上且可以被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
