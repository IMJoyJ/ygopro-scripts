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
	-- 反转：
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
c62437709.mentioned_counter={
	[0x100e]=true,
}
-- 反转效果的对象选择：选择对方场上1只表侧表示怪兽，并设置连锁操作信息为对其放置1个A指示物。
function c62437709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向玩家提示「请选择表侧表示的卡」的选择信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息：对该对象放置1个A指示物（指示物效果）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果处理：取得对象怪兽，若其仍表侧表示且与效果关联，则在其上放置1个A指示物。
function c62437709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
-- 这张卡反转时登记一个标志效果，用于标记这张卡曾经反转过。
function c62437709.flop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(62437709,RESET_EVENT+0x17a0000,0,0)
end
-- 发动条件：这张卡在墓地存在、因战斗破坏送去墓地、且带有已反转过的标志。
function c62437709.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetFlagEffect(62437709)~=0
end
-- 效果目标设定：设定抽卡玩家为自己、抽卡数量为1，并设置连锁操作信息为抽1张卡。
function c62437709.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设定为自己。
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设定为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息：自己从卡组抽1张卡（抽卡效果）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取得对象玩家和抽卡数量，让该玩家以效果原因抽相应数量的卡。
function c62437709.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让该玩家以效果原因抽1张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 攻守下降效果的适用条件：仅在伤害计算时且存在攻击对象时适用。
function c62437709.adcon(e)
	-- 判断当前处于伤害计算时且存在攻击对象（即有怪兽进行战斗）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 确定适用对象：放置有A指示物、且战斗对象是名字带有「外星」的怪兽的怪兽。
function c62437709.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算下降数值：每有1个A指示物，攻击力·守备力下降300。
function c62437709.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
