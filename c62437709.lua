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
	-- 注册反转标记：记录此卡已反转的状态
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
-- 放置A指示物发动准备：选择对方场上1只表侧表示怪兽为对象
function c62437709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：在目标怪兽上放置1个A指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 放置A指示物效果处理：在目标怪兽上放置1个A指示物
function c62437709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,1)
	end
end
-- 反转连续效果处理：为自身注册反转过的Flag标记
function c62437709.flop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(62437709,RESET_EVENT+0x17a0000,0,0)
end
-- 抽卡效果发动条件：反转过的此卡被战斗破坏送去墓地
function c62437709.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetFlagEffect(62437709)~=0
end
-- 抽卡效果发动准备：设置抽1张卡的操作信息
function c62437709.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁对象玩家为己方
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1张卡
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理：从卡组抽1张卡
function c62437709.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 攻守下降效果条件：处于伤害计算阶段且存在攻击对象
function c62437709.adcon(e)
	-- 检查是否在伤害计算阶段且双方怪兽均参与战斗
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 攻守下降目标过滤：有A指示物且与「外星」怪兽战斗的怪兽
function c62437709.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 攻守下降数值计算：根据A指示物数量每有1个下降300
function c62437709.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
