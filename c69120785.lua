--深淵の獣アルバ・ロス
-- 效果：
-- 这张卡不能通常召唤。把自己场上2只「深渊之兽」怪兽解放的场合才能从手卡·墓地特殊召唤。
-- ①：只要这个方法特殊召唤的这张卡在怪兽区域存在，场上的表侧表示的仪式·融合·同调·超量·连接怪兽的效果无效化。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。直到对方结束阶段，双方的额外卡组的里侧的卡全部表侧除外。
local s,id=GetID()
-- 注册卡片效果的初始化函数，包含特殊召唤限制、特殊召唤规则、无效场上特定怪兽效果的永续效果以及因对方效果离场时除外双方额外卡组的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- 把自己场上2只「深渊之兽」怪兽解放的场合才能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ①：只要这个方法特殊召唤的这张卡在怪兽区域存在，场上的表侧表示的仪式·融合·同调·超量·连接怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤并锁定场上表侧表示的仪式、融合、同调、超量、连接怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK))
	e2:SetCondition(s.negcon)
	c:RegisterEffect(e2)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。直到对方结束阶段，双方的额外卡组的里侧的卡全部表侧除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 检查自己场上是否存在2只可以解放的「深渊之兽」怪兽，且解放后主怪兽区有空位。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上可解放的「深渊之兽」怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsSetCard,nil,0x188)
	-- 检查是否存在2只满足解放后能腾出怪兽区域空位的「深渊之兽」怪兽。
	return g:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 玩家选择并决定要解放的2只「深渊之兽」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的「深渊之兽」怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsSetCard,nil,0x188)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足解放后有空位条件的「深渊之兽」怪兽。
	local sg=g:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 解放选中的「深渊之兽」怪兽。
	Duel.Release(sg,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 检查这张卡是否是通过自身特殊召唤规则特殊召唤的。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_VALUE_SELF)
end
-- 检查这张卡是否在表侧表示时因对方的效果从自己场上离开。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and rp==1-tp
end
-- 过滤可以被除外的双方额外卡组里侧表示的卡。
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsFacedown()
end
-- 确认双方额外卡组有里侧表示的卡，并注册除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方额外卡组中所有里侧表示的卡。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	if chk==0 then return #g>0 end
	-- 设置除外操作的信息，包含目标卡片组和数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 将双方额外卡组的里侧卡全部表侧除外，并注册在对方结束阶段将这些卡返回额外卡组的延迟效果。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方额外卡组中所有里侧表示的卡。
	local sg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	-- 将这些卡以表侧表示暂时除外，并检查是否成功除外了至少1张卡。
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0
		and sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		local c=e:GetHandler()
		-- 获取本次操作中实际被除外的卡片组。
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local tc=og:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=og:GetNext()
		end
		og:KeepAlive()
		-- 直到对方结束阶段，双方的额外卡组的里侧的卡全部表侧除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetLabelObject(og)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 注册在回合结束时触发的全局延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤带有本效果标记的卡，用于后续返回额外卡组。
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
-- 检查当前是否为对方回合的结束阶段，且被除外的卡中仍有带有标记的卡存在。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是对方回合，且被除外的卡中仍有带有标记的卡存在。
	return Duel.GetTurnPlayer()~=tp and e:GetLabelObject():IsExists(s.retfilter,1,nil)
end
-- 将被除外的卡返回双方的额外卡组。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.retfilter,nil,e:GetLabel())
	-- 将被除外的卡送回额外卡组（并洗切）。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	g:DeleteGroup()
end
