--エーリアン・グレイ
-- 效果：
-- 反转：对方场上表侧表示存在的1只怪兽放置1个A指示物。放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。此外，反转的这张卡被战斗破坏送去墓地时，从自己卡组抽1张卡。
function c62437709.initial_effect(c)
	-- 反转：对方场上表侧表示存在的1只怪兽放置1个A指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c62437709.target)
	e1:SetOperation(c62437709.operation)
	c:RegisterEffect(e1)
	-- 此外，反转的这张卡被战斗破坏送去墓地时，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c62437709.flop)
	c:RegisterEffect(e2)
	-- 此外，反转的这张卡被战斗破坏送去墓地时，从自己卡组抽1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62437709,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c62437709.drcon)
	e3:SetTarget(c62437709.drtg)
	e3:SetOperation(c62437709.drop)
	c:RegisterEffect(e3)
	-- 放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(c62437709.adcon)
	e4:SetTarget(c62437709.adtg)
	e4:SetValue(c62437709.adval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
c62437709.counter_add_list={0x100e}
-- 反转效果的目标选择与操作信息设置，确认并选择对方场上1只表侧表示的怪兽作为对象。
function c62437709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只表侧表示的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，准备为选中的怪兽放置1个A指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 反转效果的效果处理，为选择的对象怪兽放置1个A指示物。
function c62437709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
-- 反转时触发的辅助效果，给自身注册一个标记，用于记录该卡曾进行过反转。
function c62437709.flop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(62437709,RESET_EVENT+0x17a0000,0,0)
end
-- 抽卡效果的发动条件：此卡在墓地、因战斗被破坏，且带有曾反转过的标记。
function c62437709.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetFlagEffect(62437709)~=0
end
-- 抽卡效果的发动准备，设置对象玩家、抽卡数量以及抽卡操作信息。
function c62437709.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己（发动效果的玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为1。
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息，准备让玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的效果处理，获取设定的玩家和数量并执行抽卡。
function c62437709.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 攻击力·守备力下降效果的适用条件：处于伤害计算阶段，且存在攻击对象（正在进行战斗）。
function c62437709.adcon(e)
	-- 判断当前是否处于伤害计算阶段，且场上存在攻击对象。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 攻击力·守备力下降效果的适用对象过滤：自身带有A指示物，且其战斗对手是名字带有「外星」的怪兽。
function c62437709.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算攻击力·守备力下降的数值：每个A指示物使数值下降300。
function c62437709.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
