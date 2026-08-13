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
	-- 这张卡被解放送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c34614910.regcon)
	e2:SetOperation(c34614910.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被解放送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 定义可成为效果对象的植物族怪兽的筛选条件：表侧表示、植物族、等级3以上。
function c34614910.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsLevelAbove(3)
end
-- 发动代价函数：代价确认阶段检查自身是否可解放；发动时以解放手牌或场上的这张卡作为代价。
function c34614910.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放送入墓地，作为发动效果所需的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标选择函数：从自己场上选择1~2只表侧表示且等级3以上的植物族怪兽作为对象，并通过chkc校验连锁中的对象合法性、chk校验是否存在可选对象。
function c34614910.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34614910.lvfilter(chkc) end
	-- 发动合法性判断：确认自己场上存在至少1只满足lvfilter条件的植物族怪兽（自身除外），且能够作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c34614910.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择效果的对象”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1~2只满足条件的植物族怪兽作为效果对象。
	Duel.SelectTarget(tp,c34614910.lvfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- 处理时筛选函数：判断对象怪兽是否仍为表侧表示且与当前效果保持关联，确保后续效果只作用于有效的对象。
function c34614910.cfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理：对每个仍关联的对象怪兽赋予等级下降2的效果，该效果持续到回合结束时。
function c34614910.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象卡组，并筛选出仍满足cfilter（表侧且与效果关联）的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c34614910.cfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级直到回合结束时下降2星。
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
-- 登记效果触发条件：这张卡因解放而被送去墓地时，条件成立。
function c34614910.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE)
end
-- 登记效果处理：为这张卡注册编号为34614910的flag标记，该标记在回合结束阶段时重置，用于记录本回合它曾被解放送去墓地。
function c34614910.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34614910,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的发动条件：检查这张卡是否带有34614910 flag标记（即本回合被解放送去墓地过），有则可发动。
function c34614910.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34614910)>0
end
-- 特殊召唤的发动目标条件：确认自己场上存在可用怪兽区空格，且这张卡能够被效果正常特殊召唤。
function c34614910.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己的主要怪兽区是否有空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次连锁将进行特殊召唤，对象为墓地中的这张卡，数量1，由自己特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 特殊召唤的效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤；若成功，则附加“离场时改为除外”的效果。
function c34614910.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己场上，返回值非0表示召唤成功，成功后才继续附加除外效果。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
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
