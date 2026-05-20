--ゲルニア
-- 效果：
-- ①：场上的表侧表示的这张卡被对方的效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
function c77936940.initial_effect(c)
	-- ①：场上的表侧表示的这张卡被对方的效果破坏送去墓地的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c77936940.reg)
	c:RegisterEffect(e1)
	-- 下次的自己准备阶段发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77936940,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c77936940.spcon)
	e2:SetTarget(c77936940.sptg)
	e2:SetOperation(c77936940.spop)
	c:RegisterEffect(e2)
end
-- 检测这张卡是否在场上表侧表示被对方的效果破坏并送去墓地，若是则给这张卡注册一个用于标记的Flag效果
function c77936940.reg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) then
		c:RegisterFlagEffect(77936940,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 判断是否满足发动条件：不是送去墓地的当回合、当前是自己的准备阶段、且这张卡带有被对方效果破坏送墓的Flag标记
function c77936940.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 限制在送去墓地回合的下一回合及之后的自己准备阶段，且卡片带有特定的Flag标记时才能发动
	return c:GetTurnID()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(77936940)>0
end
-- 设置特殊召唤的操作信息，并在发动时重置该卡的Flag标记
function c77936940.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置当前连锁的操作信息为将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(77936940)
end
-- 效果处理时，若这张卡仍存在于墓地，则将这张卡在自己场上表侧表示特殊召唤
function c77936940.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
