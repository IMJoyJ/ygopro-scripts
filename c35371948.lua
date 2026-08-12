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
-- 检索满足条件的淘气仙星怪兽卡片组
function c35371948.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- 发动时处理：检索满足条件的淘气仙星怪兽并加入手牌
function c35371948.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足淘气仙星怪兽条件的卡组卡片
	local g=Duel.GetMatchingGroup(c35371948.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否满足发动条件并询问玩家是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35371948,0)) then  --"是否从卡组把1只「淘气仙星」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断目标卡片是否为里侧表示且在魔法与陷阱区域
function c35371948.cfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 设置效果目标并注册标记
function c35371948.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c35371948.cfilter(chkc) end
	-- 判断是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c35371948.cfilter,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	-- 提示玩家选择对方魔法与陷阱区域的盖放卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(35371948,2))  --"请选择对方的魔法与陷阱区域盖放的1张卡"
	-- 选择对方魔法与陷阱区域的盖放卡片作为目标
	local g=Duel.SelectTarget(tp,c35371948.cfilter,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	-- 获取当前连锁编号
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	g:GetFirst():RegisterFlagEffect(35371949,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,cid)
end
-- 处理效果发动并注册相关效果
function c35371948.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 获取当前连锁编号
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) and tc:GetFlagEffectLabel(35371949)==cid then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		c:ResetFlagEffect(35371948)
		tc:ResetFlagEffect(35371948)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(35371948,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc:RegisterFlagEffect(35371948,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 使目标卡片无法发动效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e1:SetLabelObject(tc)
		e1:SetCondition(c35371948.relcon)
		tc:RegisterEffect(e1)
		-- 在结束阶段强制对方发动或送入墓地
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e2:SetLabel(fid)
		e2:SetLabelObject(e1)
		e2:SetCondition(c35371948.endcon)
		e2:SetOperation(c35371948.endop)
		-- 注册结束阶段处理效果
		Duel.RegisterEffect(e2,tp)
		-- 在结束阶段强制对方发动或送入墓地
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
		-- 注册结束阶段处理效果
		Duel.RegisterEffect(e3,1-tp)
		-- 防止连锁被无效化
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EVENT_CHAINING)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
		e4:SetLabel(fid)
		e4:SetLabelObject(e3)
		e4:SetCondition(c35371948.rstcon)
		e4:SetOperation(c35371948.rstop)
		-- 注册连锁无效化处理效果
		Duel.RegisterEffect(e4,tp)
	end
end
-- 判断效果是否仍然有效
function c35371948.relcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler()) and e:GetHandler():GetFlagEffect(35371948)~=0
end
-- 判断结束阶段处理条件
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
-- 执行结束阶段处理
function c35371948.endop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	te:Reset()
	-- 显示目标卡片被选中的动画
	Duel.HintSelection(Group.FromCards(e:GetHandler()))
end
-- 判断结束阶段处理条件
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
-- 将目标卡片送入墓地
function c35371948.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标卡片送入墓地
	Duel.SendtoGrave(tc,REASON_RULE)
end
-- 判断连锁是否被无效化
function c35371948.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	return tc:GetFlagEffectLabel(35371948)==e:GetLabel()
		and c:GetFlagEffectLabel(35371948)==e:GetLabel()
end
-- 取消目标卡片的标记并重置效果
function c35371948.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	c:CancelCardTarget(tc)
	tc:ResetFlagEffect(35371948)
	local te=e:GetLabelObject()
	if te then te:Reset() end
end
-- 判断战斗伤害是否满足条件
function c35371948.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为淘气仙星怪兽造成的战斗伤害
	return ep~=tp and Duel.GetLP(1-tp)>0 and eg:GetFirst():IsSetCard(0xfb)
end
-- 判断效果伤害是否满足条件
function c35371948.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为非战斗伤害且为淘气仙星怪兽的效果
	return ep~=tp and Duel.GetLP(1-tp)>0 and bit.band(r,REASON_BATTLE)==0 and re
		and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xfb)
end
-- 造成200点伤害
function c35371948.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动动画
	Duel.Hint(HINT_CARD,0,35371948)
	-- 对对方造成200点伤害
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
