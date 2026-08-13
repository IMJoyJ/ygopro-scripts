--トリックスター・ライトステージ
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「淘气仙星」怪兽加入手卡。
-- ②：1回合1次，以对方的魔法与陷阱区域1张里侧表示卡为对象才能发动。只要这张卡在场地区域存在，那张里侧表示卡直到结束阶段不能发动，对方在结束阶段必须把那张卡发动或送去墓地。
-- ③：每次自己场上的「淘气仙星」怪兽用战斗·效果给与对方伤害，给与对方200伤害。
function c35371948.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「淘气仙星」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c35371948.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方的魔法与陷阱区域1张里侧表示卡为对象才能发动。只要这张卡在场地区域存在，那张里侧表示卡直到结束阶段不能发动，对方在结束阶段必须把那张卡发动或送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35371948,1))  --"限制发动"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c35371948.target)
	e2:SetOperation(c35371948.operation)
	c:RegisterEffect(e2)
	-- ③：每次自己场上的「淘气仙星」怪兽用战斗·效果给与对方伤害，给与对方200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c35371948.damcon1)
	e3:SetOperation(c35371948.damop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DAMAGE)
	e4:SetCondition(c35371948.damcon2)
	c:RegisterEffect(e4)
end
-- 定义检索过滤条件：卡是怪兽卡、属于「淘气仙星」系列，并且可以被加入手卡。
function c35371948.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- ①效果的处理函数：从卡组筛选出符合条件的「淘气仙星」怪兽，若存在则询问玩家是否检索，同意后选择1张加入手卡并向对方展示。
function c35371948.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足检索条件的「淘气仙星」怪兽。
	local g=Duel.GetMatchingGroup(c35371948.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在可检索的怪兽，且我方玩家确认发动检索，则继续执行加入手卡的处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35371948,0)) then  --"是否从卡组把1只「淘气仙星」怪兽加入手卡？"
		-- 弹出选择卡片的提示，要求我方从检索结果中选择1张要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的那张「淘气仙星」怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认我方加入手卡的那张卡，使检索结果公开。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义取对象过滤条件：对象必须是对方里侧表示、且位于对方魔法与陷阱区域（0～4号区域）的卡，对方场地区（5号区域）的卡不算在内。
function c35371948.cfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- ②效果的目标选择函数：进行合法性检查并选择对方魔陷区1张里侧卡作为对象，同时把当前连锁ID记录在该卡上，供处理时确认对象没有被替换。
function c35371948.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c35371948.cfilter(chkc) end
	-- 发动时合法性的检查：确认对方魔陷区存在1张可选的里侧卡，并且该卡能成为此效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c35371948.cfilter,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	-- 显示选择提示：请选择对方的魔法与陷阱区域盖放的1张卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(35371948,2))  --"请选择对方的魔法与陷阱区域盖放的1张卡"
	-- 实际选择对方魔陷区1张里侧卡作为本连锁的对象，并将该卡锁定为效果对象。
	local g=Duel.SelectTarget(tp,c35371948.cfilter,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	-- 获取当前连锁的ID，用于之后校验该对象卡仍是当初选择的那张卡。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	g:GetFirst():RegisterFlagEffect(35371949,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,cid)
end
-- ②效果处理：确认场地魔法和对象卡都仍然有效后，将对象卡设为灯光舞台的卡片对象；为对象卡附加“不能发动”限制，并安排结束阶段解除限制、若仍未发动则送去墓地，同时检测对象卡发动连锁以解除锁定。
function c35371948.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次效果发动时选择的对象卡（里侧表示的那张卡）。
	local tc=Duel.GetFirstTarget()
	-- 取得当前处理中的连锁ID，用于确认对象卡仍与本次连锁相关。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) and tc:GetFlagEffectLabel(35371949)==cid then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		c:ResetFlagEffect(35371948)
		tc:ResetFlagEffect(35371948)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(35371948,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc:RegisterFlagEffect(35371948,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 那张里侧表示卡直到结束阶段不能发动
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e1:SetLabelObject(tc)
		e1:SetCondition(c35371948.relcon)
		tc:RegisterEffect(e1)
		-- 那张里侧表示卡直到结束阶段不能发动，对方在结束阶段必须把那张卡发动或送去墓地。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e2:SetLabel(fid)
		e2:SetLabelObject(e1)
		e2:SetCondition(c35371948.endcon)
		e2:SetOperation(c35371948.endop)
		-- 将“结束阶段解除不能发动限制”的辅助效果注册到当前决斗中，使该效果由灯光舞台的控制者在结束阶段处理。
		Duel.RegisterEffect(e2,tp)
		-- 对方在结束阶段必须把那张卡发动或送去墓地。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c35371948.tgcon)
		e3:SetOperation(c35371948.tgop)
		-- 将“结束阶段若对象仍未发动则送去墓地”的效果注册到对方玩家的结束阶段处理流程中。
		Duel.RegisterEffect(e3,1-tp)
		-- 那张里侧表示卡直到结束阶段不能发动，对方在结束阶段必须把那张卡发动或送去墓地。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EVENT_CHAINING)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e4:SetLabel(fid)
		e4:SetLabelObject(e3)
		e4:SetCondition(c35371948.rstcon)
		e4:SetOperation(c35371948.rstop)
		-- 将“检测对象卡是否发动连锁并解除锁定”的辅助效果注册到当前决斗中，以在对象卡发动时及时取消灯光舞台对它的锁定状态。
		Duel.RegisterEffect(e4,tp)
	end
end
-- “不能发动”限制的持续条件：灯光舞台仍以该卡为卡片对象，且该卡仍带有锁定标记，限制才继续适用。
function c35371948.relcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler()) and e:GetHandler():GetFlagEffect(35371948)~=0
end
-- 结束阶段解除限制的条件：灯光舞台与对象卡仍带着相同的锁定标记，且灯光舞台效果未被无效；否则重置该结束阶段处理效果。
function c35371948.endcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject():GetLabelObject()
	if tc:GetFlagEffectLabel(35371948)==e:GetLabel()
		and c:GetFlagEffectLabel(35371948)==e:GetLabel() then
		return not c:IsDisabled()
	else
		e:Reset()
		return false
	end
end
-- 结束阶段解除限制的处理：重置对象卡上的“不能发动”效果，并展示灯光舞台提示限制已解除。
function c35371948.endop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	te:Reset()
	-- 手动展示灯光舞台并播放选中动画，用于提示结束阶段已到、对方可以选择发动该对象卡。
	Duel.HintSelection(Group.FromCards(e:GetHandler()))
end
-- 结束阶段送墓的条件：灯光舞台与对象卡仍带相同锁定标记，且灯光舞台效果未被无效；若已不满足则重置该送墓效果。
function c35371948.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(35371948)==e:GetLabel()
		and c:GetFlagEffectLabel(35371948)==e:GetLabel() then
		return not c:IsDisabled()
	else
		e:Reset()
		return false
	end
end
-- 结束阶段送墓的处理：将仍处于锁定状态的对象卡以规则原因送去墓地。
function c35371948.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 把仍未发动/仍未摆脱锁定的对象卡以规则原因送去墓地，实现“对方在结束阶段必须把那张卡发动或送去墓地”中的送墓分支。
	Duel.SendtoGrave(tc,REASON_RULE)
end
-- 对象卡发动连锁时的触发条件：当前连锁的卡正是被锁定且带有相同锁定标记的对象卡，同时灯光舞台也仍带锁定标记。
function c35371948.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	return tc:GetFlagEffectLabel(35371948)==e:GetLabel()
		and c:GetFlagEffectLabel(35371948)==e:GetLabel()
end
-- 对象卡发动时解除锁定：灯光舞台取消对该卡的目标指向，清除对象卡上的锁定标记，并重置相关结束阶段辅助效果，使该卡可以正常发动。
function c35371948.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	c:CancelCardTarget(tc)
	tc:ResetFlagEffect(35371948)
	local te=e:GetLabelObject()
	if te then te:Reset() end
end
-- 战斗伤害的触发条件：受伤害的是对方玩家、对方LP仍大于0，且造成该战斗伤害的怪兽是「淘气仙星」怪兽。
function c35371948.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定满足：对方受到战斗伤害、伤害后对方LP仍为正数，且伤害来源为「淘气仙星」怪兽。
	return ep~=tp and Duel.GetLP(1-tp)>0 and eg:GetFirst():IsSetCard(0xfb)
end
-- 效果伤害的触发条件：受伤害的是对方玩家、对方LP仍大于0、本次伤害不是战斗伤害，且伤害效果来源于「淘气仙星」怪兽。
function c35371948.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 条件前半部分：对方受到伤害且LP仍大于0，并且这次伤害不是战斗伤害，同时存在造成伤害的效果来源re。
	return ep~=tp and Duel.GetLP(1-tp)>0 and bit.band(r,REASON_BATTLE)==0 and re
		and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xfb)
end
-- 追加伤害的处理函数：播放灯光舞台的卡片动画，然后给对方造成200点效果伤害。
function c35371948.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示「淘气仙星·灯光舞台」的卡图，提示③效果正在处理。
	Duel.Hint(HINT_CARD,0,35371948)
	-- 给对方玩家造成200点效果伤害，作为③效果的追加伤害。
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
