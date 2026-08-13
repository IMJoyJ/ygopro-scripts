--花札衛－雨四光－
-- 效果：
-- 调整＋调整以外的怪兽3只
-- ①：只要这张卡在怪兽区域存在，自己场上的「花札卫」怪兽不会被效果破坏，不会成为对方的效果的对象。
-- ②：对方抽卡阶段对方通常抽卡的场合发动。给与对方1500伤害。
-- ③：对方结束阶段从以下效果选择1个发动。
-- ●下次的自己回合的抽卡阶段跳过。
-- ●这张卡的效果直到下次的对方准备阶段无效。
function c42291297.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（不指定具体种族/属性，nil表示任意调整）和3只调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),3,3)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己场上的「花札卫」怪兽不会被效果破坏（此段代码注册的是“不会被效果破坏”部分）。
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的影响对象：仅限于自己场上卡名含有「花札卫」（0xe6）字段的卡。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe6))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置“不能成为效果对象”的判定函数：当效果发动者不是这张卡的控制者时返回真，即对方的效果不能以自己场上的「花札卫」怪兽为对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：对方抽卡阶段对方通常抽卡的场合发动。给与对方1500伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42291297,0))  --"给与对方1500伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DRAW)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c42291297.damcon)
	e4:SetTarget(c42291297.damtg)
	e4:SetOperation(c42291297.damop)
	c:RegisterEffect(e4)
	-- ③：对方结束阶段从以下效果选择1个发动。●下次的自己回合的抽卡阶段跳过。●这张卡的效果直到下次的对方准备阶段无效。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c42291297.epcon)
	e5:SetTarget(c42291297.eptg)
	e5:SetOperation(c42291297.epop)
	c:RegisterEffect(e5)
end
-- 伤害效果发动条件：抽卡玩家不是这张卡的控制者，且抽卡原因是规则通常抽卡（REASON_RULE）。
function c42291297.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_RULE
end
-- 伤害效果的发动目标处理：满足条件即可发动，将对象玩家设为对方、伤害参数设为1500，并登记伤害操作信息。
function c42291297.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1500，即要造成的伤害数值。
	Duel.SetTargetParam(1500)
	-- 向系统登记将造成1500点效果伤害的操作信息，供相关卡片连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 伤害效果处理：从连锁信息中取出对象玩家和伤害值，执行伤害。
function c42291297.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象玩家（p）和对象参数（d，即伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：当前回合玩家不是这张卡的控制者，即对方回合的结束阶段。
function c42291297.epcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不等于这张卡的控制者，满足时返回真，确保只在对方回合触发。
	return Duel.GetTurnPlayer()~=tp
end
-- ③效果的目标处理：发动时让控制者选择“跳过下次自己回合抽卡阶段”或“这张卡的效果直到下次对方准备阶段无效”；若这张卡当前可被无效则提供两个选项，否则只提供跳过抽卡阶段的选项。
function c42291297.eptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local op=0
	-- 显示“请选择要发动的效果”的选择提示，并将该消息作为后续选项选择的提示缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 如果这张卡是表侧表示且其效果可被无效，则给出两个选项：选项0为跳过下次自己回合抽卡阶段，选项1为这张卡的效果直到下次对方准备阶段无效。
	if aux.NegateMonsterFilter(c) then op=Duel.SelectOption(tp,aux.Stringid(42291297,1),aux.Stringid(42291297,2))  --"下次的自己回合的抽卡阶段跳过/这张卡的效果直到下次的对方准备阶段无效"
	-- 否则只给出一个选项“下次的自己回合的抽卡阶段跳过”，并选择该选项（op=0）。
	else op=Duel.SelectOption(tp,aux.Stringid(42291297,1)) end  --"下次的自己回合的抽卡阶段跳过"
	if op==0 then
		e:SetCategory(0)
	else
		e:SetCategory(CATEGORY_DISABLE)
		-- 当选择“使这张卡效果无效”时，登记将使该卡效果无效（CATEGORY_DISABLE）的操作信息，目标为这张卡自身。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,c,1,0,0)
	end
	e:SetLabel(op)
end
-- ③效果的处理：根据目标阶段选择的选项执行对应效果——若选择跳过抽卡阶段，则为控制者注册跳过下次自己抽卡阶段的效果；若选择无效效果，且该卡仍在场上表侧表示且与效果相关，则无效这张卡及其相关连锁，使其效果无效直到下次对方准备阶段。
function c42291297.epop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- ●下次的自己回合的抽卡阶段跳过。（当选择该选项时，创建并注册一个影响玩家的跳过抽卡阶段效果，持续到下次自己的回合结束阶段）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		-- 将跳过抽卡阶段的效果注册给这张卡的控制者tp，在重置前（下次自己的回合结束阶段）会跳过其抽卡阶段。
		Duel.RegisterEffect(e1,tp)
	elseif c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使与这张卡相关的连锁全部无效化，并设置重置标志RESET_TURN_SET，用于实现“这张卡的效果直到下次的对方准备阶段无效”的无效果管理。
		Duel.NegateRelatedChain(c,RESET_TURN_SET)
		-- ●这张卡的效果直到下次的对方准备阶段无效。（创建并注册使这张卡效果无效的永续效果，并在下次对方准备阶段时重置）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		c:RegisterEffect(e2)
	end
end
