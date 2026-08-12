--トリックスター・ライトアリーナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己把「淘气仙星」怪兽连接召唤的场合，以作为那些素材的自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
-- ②：1回合1次，以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。只要这张卡存在，盖放的那张卡直到结束阶段不能发动，对方在结束阶段必须让那张卡发动或回到手卡。
function c63492244.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己把「淘气仙星」怪兽连接召唤的场合，以作为那些素材的自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63492244,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,63492244)
	e2:SetCondition(c63492244.spcon)
	e2:SetTarget(c63492244.sptg)
	e2:SetOperation(c63492244.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。只要这张卡存在，盖放的那张卡直到结束阶段不能发动，对方在结束阶段必须让那张卡发动或回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63492244,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,63492245)
	e3:SetTarget(c63492244.target)
	e3:SetOperation(c63492244.operation)
	c:RegisterEffect(e3)
end
-- 检查是否是自己把「淘气仙星」怪兽连接召唤成功
function c63492244.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsSetCard(0xfb) and ec:IsSummonType(SUMMON_TYPE_LINK) and ec:IsSummonPlayer(tp)
end
-- 过滤在自己墓地、是「淘气仙星」怪兽、可以成为效果对象且可以守备表示特殊召唤的卡
function c63492244.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsSetCard(0xfb)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备，获取连接素材并选择其中1只作为对象
function c63492244.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:GetFirst():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c63492244.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c63492244.spfilter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c63492244.spfilter,1,1,nil,e,tp)
	-- 将选择的卡设置为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
	-- 设置特殊召唤的操作信息，包含特殊召唤的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理，将作为对象的怪兽效果无效并守备表示特殊召唤
function c63492244.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，并尝试将其以表侧守备表示特殊召唤
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 过滤对方魔法与陷阱区域盖放的卡
function c63492244.cfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 效果②的发动准备，选择对方魔法与陷阱区域盖放的1张卡作为对象，并记录连锁ID
function c63492244.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c63492244.cfilter(chkc) end
	-- 检查对方魔法与陷阱区域是否存在可以作为对象的盖放卡
	if chk==0 then return Duel.IsExistingTarget(c63492244.cfilter,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	-- 提示玩家选择对方魔法与陷阱区域盖放的1张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63492244,2))  --"请选择对方的魔法与陷阱区域盖放的1张卡"
	-- 玩家选择对方魔法与陷阱区域盖放的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c63492244.cfilter,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	g:GetFirst():RegisterFlagEffect(63492245,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,cid)
end
-- 效果②的效果处理，使盖放的卡不能发动，并注册结束阶段强制发动或回手卡的效果
function c63492244.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的对方盖放卡
	local tc=Duel.GetFirstTarget()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) and tc:GetFlagEffectLabel(63492245)==cid then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		c:ResetFlagEffect(63492244)
		tc:ResetFlagEffect(63492244)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(63492244,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc:RegisterFlagEffect(63492244,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 盖放的那张卡直到结束阶段不能发动
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e1:SetLabelObject(tc)
		e1:SetCondition(c63492244.relcon)
		tc:RegisterEffect(e1)
		-- 直到结束阶段不能发动
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e2:SetLabel(fid)
		e2:SetLabelObject(e1)
		e2:SetCondition(c63492244.endcon)
		e2:SetOperation(c63492244.endop)
		-- 将在结束阶段解除不能发动限制的效果注册给当前玩家
		Duel.RegisterEffect(e2,tp)
		-- 对方在结束阶段必须让那张卡发动或回到手卡。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c63492244.thcon)
		e3:SetOperation(c63492244.thop)
		-- 将在结束阶段强制回手卡的效果注册给对方玩家
		Duel.RegisterEffect(e3,1-tp)
		-- 对方在结束阶段必须让那张卡发动或回到手卡。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EVENT_CHAINING)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e4:SetLabel(fid)
		e4:SetLabelObject(e3)
		e4:SetCondition(c63492244.rstcon)
		e4:SetOperation(c63492244.rstop)
		-- 注册一个在对方发动该卡时重置回手卡效果的事件监听效果
		Duel.RegisterEffect(e4,tp)
	end
end
-- 检查场地魔法是否依然对该卡保持对象指向关系
function c63492244.relcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler()) and e:GetHandler():GetFlagEffect(63492244)~=0
end
-- 检查结束阶段解除不能发动限制的效果是否满足发动条件
function c63492244.endcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject():GetLabelObject()
	if tc:GetFlagEffectLabel(63492244)==e:GetLabel()
		and c:GetFlagEffectLabel(63492244)==e:GetLabel() then
		return not c:IsDisabled()
	else
		e:Reset()
		return false
	end
end
-- 在结束阶段解除该卡不能发动的限制，并显示场地魔法的选中动画
function c63492244.endop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	te:Reset()
	-- 手动显示场地魔法被选中的动画效果
	Duel.HintSelection(Group.FromCards(e:GetHandler()))
end
-- 检查结束阶段强制回手卡的效果是否满足发动条件
function c63492244.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(63492244)==e:GetLabel()
		and c:GetFlagEffectLabel(63492244)==e:GetLabel() then
		return not c:IsDisabled()
	else
		e:Reset()
		return false
	end
end
-- 在结束阶段将该卡送回持有者手卡
function c63492244.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将目标卡片送回持有者的手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 检查发动的卡是否是受到此卡效果影响的卡
function c63492244.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	return tc:GetFlagEffectLabel(63492244)==e:GetLabel()
		and c:GetFlagEffectLabel(63492244)==e:GetLabel()
end
-- 当受影响的卡发动时，解除对象关系并重置相关的结束阶段回手卡效果
function c63492244.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	c:CancelCardTarget(tc)
	tc:ResetFlagEffect(63492244)
	local te=e:GetLabelObject()
	if te then te:Reset() end
end
