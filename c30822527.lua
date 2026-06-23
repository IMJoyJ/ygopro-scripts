--デコード・トーカー・エクステンド
-- 效果：
-- 效果怪兽2只以上
-- ①：这张卡只要在怪兽区域存在，卡名当作「解码语者」使用。
-- ②：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
-- ③：自己战斗阶段，这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c30822527.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2只效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- 使该卡在怪兽区域存在时，卡号视为「解码语者」
	aux.EnableChangeCode(c,1861629)
	-- 这张卡的攻击力上升这张卡所连接区的怪兽数量×500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c30822527.atkval)
	c:RegisterEffect(e2)
	-- 自己战斗阶段，这张卡所连接区的怪兽被战斗破坏的场合才能发动
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
	-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击
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
-- 返回该卡所连接区怪兽数量乘以500的攻击力
function c30822527.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
-- 判断怪兽是否从怪兽区域离开且处于指定连接区
function c30822527.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 判断被战斗破坏的怪兽是否在连接区范围内
function c30822527.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30822527.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 过滤掉因战斗破坏而离开的怪兽
function c30822527.cfilter2(c,tp,zone)
	return not c:IsReason(REASON_BATTLE) and c30822527.cfilter(c,tp,zone)
end
-- 判断被送去墓地的怪兽是否在连接区范围内
function c30822527.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30822527.cfilter2,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 触发自定义事件，用于激活效果
function c30822527.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发编号为EVENT_CUSTOM+30822527的单体事件
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+30822527,e,0,tp,0,0)
end
-- 判断是否为自己的战斗阶段
function c30822527.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡控制者
	return Duel.GetTurnPlayer()==tp
		-- 判断当前阶段是否为战斗阶段开始到战斗阶段结束之间
		and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 检查是否已拥有额外攻击效果
function c30822527.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- 为该卡添加一次额外攻击效果
function c30822527.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 为该卡添加一次额外攻击效果，持续到结束阶段
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
