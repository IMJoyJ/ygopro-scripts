--颶風龍－ビュフォート・ノウェム
-- 效果：
-- 「褒誉之息吹」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的直接攻击宣言时把这张卡从手卡丢弃才能发动。那次攻击无效，那只怪兽的效果无效化。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡回到持有者手卡。这个效果在对方回合也能发动。
function c8836329.initial_effect(c)
	aux.AddCodeList(c,44221928)
	c:EnableReviveLimit()
	-- ①：对方怪兽的直接攻击宣言时把这张卡从手卡丢弃才能发动。那次攻击无效，那只怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8836329,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,8836329)
	e1:SetCondition(c8836329.discon)
	e1:SetCost(c8836329.discost)
	e1:SetTarget(c8836329.distg)
	e1:SetOperation(c8836329.disop)
	c:RegisterEffect(e1)
	-- ②：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡回到持有者手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8836329,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,8836330)
	e2:SetTarget(c8836329.thtg)
	e2:SetOperation(c8836329.thop)
	c:RegisterEffect(e2)
end
-- 1效果的发动条件判定函数（对方怪兽直接攻击宣言时）
function c8836329.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前进行攻击宣言的怪兽作为标签对象保存，以便后续效果处理时获取
	e:SetLabelObject(Duel.GetAttacker())
	-- 判定攻击怪兽的控制者为对方，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 1效果的发动代价处理函数（从手卡丢弃自身）
function c8836329.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 1效果的发动准备与效果分类声明函数
function c8836329.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置连锁信息，表示该效果包含无效怪兽效果的操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,bc,1,0,0)
end
-- 1效果的效果处理函数（无效攻击并无效该怪兽效果）
function c8836329.disop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	-- 成功无效攻击，且攻击怪兽仍在场上表侧表示、未被无效时，继续处理无效效果
	if Duel.NegateAttack() and bc and bc:IsRelateToBattle() and bc:IsFaceup() and not bc:IsDisabled() then
		-- 无效与该怪兽相关的连锁
		Duel.NegateRelatedChain(bc,RESET_TURN_SET)
		-- 那只怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		-- 那只怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e2)
	end
end
-- 2效果的过滤条件函数（对方场上表侧表示且能回到手牌的怪兽）
function c8836329.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 2效果的发动准备与取对象处理函数
function c8836329.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c8836329.thfilter(chkc) end
	-- 判定自身能回到手牌，且对方场上存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(c8836329.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择返回手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8836329.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(c)
	-- 设置连锁信息，表示该效果包含将2张卡送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 2效果的效果处理函数（将自身和对象怪兽回到手牌）
function c8836329.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取2效果选择的对方怪兽对象
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local rg=Group.FromCards(c,tc)
	-- 将自身与对象怪兽送回持有者手牌
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
end
