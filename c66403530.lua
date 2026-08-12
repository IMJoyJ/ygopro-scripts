--トポロジック・ゼロヴォロス
-- 效果：
-- 效果怪兽2只以上
-- 自己不能在作为这张卡所连接区的额外怪兽区域让怪兽出现。
-- ①：这张卡的攻击力上升除外状态的卡数量×200。
-- ②：这张卡在怪兽区域存在的状态，连接怪兽所连接区有怪兽特殊召唤的场合发动。场上的卡全部除外。
-- ③：这张卡被自身的效果除外的场合，下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
function c66403530.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 自己不能在作为这张卡所连接区的额外怪兽区域让怪兽出现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c66403530.zonelimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升除外状态的卡数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c66403530.value)
	c:RegisterEffect(e2)
	-- ②：这张卡在怪兽区域存在的状态，连接怪兽所连接区有怪兽特殊召唤的场合发动。场上的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66403530,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c66403530.rmcon)
	e3:SetTarget(c66403530.rmtg)
	e3:SetOperation(c66403530.rmop)
	c:RegisterEffect(e3)
	-- ③：这张卡被自身的效果除外的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_REMOVE)
	e4:SetOperation(c66403530.spreg)
	c:RegisterEffect(e4)
	-- 下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66403530,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCondition(c66403530.spcon)
	e5:SetTarget(c66403530.sptg)
	e5:SetOperation(c66403530.spop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 计算自身所连接的额外怪兽区域掩码，用于限制自己不能在这些区域让怪兽出现
function c66403530.zonelimit(e)
	return 0x1f001f | (0x600060 & ~e:GetHandler():GetLinkedZone())
end
-- 计算攻击力上升值的辅助函数
function c66403530.value(e,c)
	-- 返回双方除外状态的卡片数量乘以200的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*200
end
-- 过滤函数：判断特殊召唤的怪兽是否处于连接怪兽所连接的区域
function c66403530.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:IsPreviousControler(1) then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0
end
-- 场上卡片全部除外效果的发动条件：有怪兽特殊召唤到连接怪兽所连接的区域，且该怪兽不含自身
function c66403530.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方玩家场上所有连接怪兽所连接的区域掩码
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c66403530.cfilter,1,nil,zone)
end
-- 场上卡片全部除外效果的发动准备：获取场上所有的卡，并设置除外操作信息
function c66403530.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置除外场上所有卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 场上卡片全部除外效果的执行：获取场上所有的卡并将其表侧表示除外
function c66403530.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将获取到的卡片全部表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 自身被除外时的辅助效果：判断是否被自身效果除外，并记录下个回合数和注册标记
function c66403530.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_EFFECT) and rc==c then
		-- 将效果的Label值设置为下个回合的回合数
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(66403530,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 特殊召唤效果的发动条件：当前回合数等于记录的下个回合数，且自身带有特定的标记
function c66403530.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为下个回合，且自身是否带有被自身效果除外的标记
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(66403530)>0
end
-- 特殊召唤效果的发动准备：设置特殊召唤自身的操作信息，并重置标记
function c66403530.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤除外状态的这张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(66403530)
end
-- 特殊召唤效果的执行：如果自身仍存在于除外区，则将其特殊召唤到场上
function c66403530.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
