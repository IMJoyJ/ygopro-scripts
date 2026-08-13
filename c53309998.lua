--シーアーカイバー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，场上的连接怪兽所连接区有怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c53309998.initial_effect(c)
	-- 为卡片注册“已在墓地”的标记检测效果，用于记录此卡在墓地的状态，以正确判断本卡在手卡·墓地存在时的发动条件。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，场上的连接怪兽所连接区有怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 过滤函数：根据怪兽当前或变化前的位置计算其所在区域，检查该区域是否为连接怪兽所连接的区域（通过zone位图判断），并且该怪兽的召唤/特殊召唤不是由本卡效果自身触发，用于筛选eg中满足发动条件的召唤/特殊召唤怪兽。
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
-- 发动条件判定：获取本次召唤/特殊召唤成功的怪兽集合eg，检查是否存在至少1只被召唤/特殊召唤到连接区且诱发原因不是本卡效果的怪兽；若存在，则满足“场上的连接怪兽所连接区有怪兽召唤·特殊召唤”的发动条件。
function c53309998.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	-- 获取双方场上所有连接怪兽所连接区的位图：低16位表示玩家0的连接区，高16位表示玩家1的连接区，供后续判断被召唤怪兽是否落在这些区域。
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return eg:IsExists(c53309998.cfilter,1,nil,zone,se)
end
-- 特殊召唤的目标/发动合法性判定：效果发动时确认自己场上是否有可用的主要怪兽区，且此卡能够被特殊召唤（满足苏生限制和特殊召唤手续）。
function c53309998.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查条件：己方主要怪兽区存在空格，且此卡可以被特殊召唤；满足则效果可以发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本效果将执行特殊召唤操作：对象为效果持有者自身，数量为1，用于连锁和效果发动时的信息记录。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：确认此卡仍与效果关联后将其特殊召唤；若特殊召唤成功，则给此卡附加一个不可无效的“离场时除外”的持续效果。
function c53309998.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍然与当前效果存在关联（未被无效或移动），然后以表侧表示特殊召唤此卡；只有召唤成功时才继续赋予离场除外效果。
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
