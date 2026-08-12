--シューティング・ソニック
-- 效果：
-- ①：以自己场上1只「星尘」同调怪兽为对象才能发动。这个回合，那只自己的同调怪兽和对方怪兽进行战斗的场合，伤害步骤开始时那只对方怪兽回到持有者卡组。
-- ②：自己场上的「星尘」同调怪兽为让效果发动而把自身解放的场合，可以作为代替把墓地的这张卡除外。
function c84012625.initial_effect(c)
	-- ①：以自己场上1只「星尘」同调怪兽为对象才能发动。这个回合，那只自己的同调怪兽和对方怪兽进行战斗的场合，伤害步骤开始时那只对方怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果的发动条件为：当前能够进入战斗阶段，或者正处于战斗阶段中。
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c84012625.target)
	e1:SetOperation(c84012625.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「星尘」同调怪兽为让效果发动而把自身解放的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(84012625)
	e2:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「星尘」同调怪兽。
function c84012625.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO)
end
-- 效果①的发动准备与目标选择，确认场上是否存在符合条件的「星尘」同调怪兽并将其选择为效果对象。
function c84012625.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c84012625.filter(chkc) end
	-- 在发动阶段的检查步骤，判断自己场上是否存在至少1只可以作为效果对象的表侧表示「星尘」同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(c84012625.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动效果的玩家选择1只符合条件的「星尘」同调怪兽作为效果的对象。
	Duel.SelectTarget(tp,c84012625.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：获取选择的对象，若其仍表侧表示且与效果相关联，则为其注册一个在伤害步骤开始时触发的单回合时效效果。
function c84012625.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，那只自己的同调怪兽和对方怪兽进行战斗的场合，伤害步骤开始时那只对方怪兽回到持有者卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetOwnerPlayer(tp)
		e1:SetCondition(c84012625.tdcon)
		e1:SetOperation(c84012625.tdop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 判断战斗开始时的触发条件：当前进行战斗的怪兽存在且为对方场上的怪兽。
function c84012625.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tp==e:GetOwnerPlayer() and tc and tc:IsControler(1-tp)
end
-- 执行战斗开始时的效果处理：获取进行战斗的对方怪兽，并将其送回持有者的卡组并洗牌。
function c84012625.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 将目标怪兽送回持有者的卡组并洗牌。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
