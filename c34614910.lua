--六花精シクラン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡解放，以自己场上最多2只植物族怪兽为对象才能发动。那些怪兽的等级直到回合结束时下降2星。
-- ②：这张卡被解放送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c34614910.initial_effect(c)
	-- ①：把手卡·场上的这张卡解放，以自己场上最多2只植物族怪兽为对象才能发动。那些怪兽的等级直到回合结束时下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34614910,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,34614910)
	e1:SetCost(c34614910.lvcost)
	e1:SetTarget(c34614910.lvtg)
	e1:SetOperation(c34614910.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c34614910.regcon)
	e2:SetOperation(c34614910.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34614910,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,34614911)
	e3:SetCondition(c34614910.spcon)
	e3:SetTarget(c34614910.sptg)
	e3:SetOperation(c34614910.spop)
	c:RegisterEffect(e3)
end
-- 筛选场上我方的植物族怪兽，且等级大于等于3的怪兽
function c34614910.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsLevelAbove(3)
end
-- 支付效果的解放费用，将自身从场上解放
function c34614910.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 选择场上我方的植物族怪兽作为效果的对象，最多选择2只
function c34614910.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34614910.lvfilter(chkc) end
	-- 确认场上是否存在我方的植物族怪兽作为效果的对象
	if chk==0 then return Duel.IsExistingTarget(c34614910.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上我方的植物族怪兽作为效果的对象，最多选择2只
	Duel.SelectTarget(tp,c34614910.lvfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- 筛选场上我方的怪兽，且这些怪兽与当前效果相关联
function c34614910.cfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 将选择的怪兽等级下降2星，持续到回合结束
function c34614910.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的对象卡片组，并筛选出与当前效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c34614910.cfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 给目标怪兽添加等级下降2的效果，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 判断此卡是否因解放而送去墓地
function c34614910.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE)
end
-- 为该卡注册一个标记，用于记录其因解放而进入墓地
function c34614910.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34614910,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断该卡是否拥有因解放而进入墓地的标记
function c34614910.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34614910)>0
end
-- 判断是否可以将此卡特殊召唤到场上
function c34614910.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置此效果的处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作，并在特殊召唤成功后添加离开场上的处理
function c34614910.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，如果成功则继续处理后续效果
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 当此卡从场上离开时，将其移除
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
