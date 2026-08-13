--デコード・トーカー・エクステンド
-- 效果：
-- 效果怪兽2只以上
-- ①：这张卡只要在怪兽区域存在，卡名当作「解码语者」使用。
-- ②：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
-- ③：自己战斗阶段，这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c30822527.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，要求以2只效果怪兽作为连接素材（对应召唤条件「效果怪兽2只以上」）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- 为这张卡注册在怪兽区域时卡名当作「解码语者」（卡号1861629）使用的永续效果（对应①效果）。
	aux.EnableChangeCode(c,1861629)
	-- ②：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c30822527.atkval)
	c:RegisterEffect(e2)
	-- 这张卡所连接区的怪兽被战斗破坏的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c30822527.regcon)
	e3:SetOperation(c30822527.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c30822527.regcon2)
	c:RegisterEffect(e4)
	-- ③：自己战斗阶段，这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(30822527,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CUSTOM+30822527)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c30822527.atkcon)
	e5:SetTarget(c30822527.atktg)
	e5:SetOperation(c30822527.atkop)
	c:RegisterEffect(e5)
end
-- 计算这张卡所连接区的怪兽数量（GetLinkedGroupCount）并乘以500，作为攻击力上升数值。
function c30822527.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
-- 过滤函数：判断怪兽是否在从这张卡所连接的区域被战斗破坏或送去墓地，通过之前所在区域序号和连接区掩码判断是否位于这张卡的连接区。
function c30822527.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- e3的战斗破坏事件条件：事件组eg中存在至少一只从这张卡所连接区被战斗破坏的怪兽。
function c30822527.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30822527.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 在cfilter基础上额外排除因战斗破坏（REASON_BATTLE）而送墓的情况，用于筛选中「被送去墓地」事件的非战斗破坏送墓。
function c30822527.cfilter2(c,tp,zone)
	return not c:IsReason(REASON_BATTLE) and c30822527.cfilter(c,tp,zone)
end
-- e4的送去墓地事件条件：事件组eg中存在至少一只从这张卡所连接区以非战斗破坏方式送去墓地的怪兽。
function c30822527.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30822527.cfilter2,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 当满足触发条件时，给这张卡自身触发一个自定义事件（EVENT_CUSTOM+30822527），供e5效果发动。
function c30822527.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 向这张卡自身发送自定义事件，通知「连接区怪兽被战破/送墓」已发生，从而激活e5的发动时点。
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+30822527,e,0,tp,0,0)
end
-- e5的发动条件：当前为这张卡控制者的战斗阶段。
function c30822527.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者（即自己回合）。
	return Duel.GetTurnPlayer()==tp
		-- 且当前阶段处于战斗阶段开始到战斗阶段结束之间（即战斗阶段内）。
		and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 发动可执行判定：这张卡尚未持有EFFECT_EXTRA_ATTACK效果时才可发动，防止重复叠加攻击次数。
function c30822527.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- 效果处理：为这张卡注册「额外攻击次数+1」的效果，持续到结束阶段，使本回合这张卡可以攻击2次。
function c30822527.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
