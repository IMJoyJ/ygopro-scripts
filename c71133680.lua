--水精鱗－ネレイアビス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己场上1只水属性怪兽为对象才能发动。选那只怪兽以外的自己的手卡·场上1只水属性怪兽破坏，作为对象的怪兽的攻击力·守备力直到回合结束时上升这个效果破坏的怪兽的原本数值。这个效果在对方回合也能发动。
-- ②：这张卡从场上送去墓地的场合才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
function c71133680.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以自己场上1只水属性怪兽为对象才能发动。选那只怪兽以外的自己的手卡·场上1只水属性怪兽破坏，作为对象的怪兽的攻击力·守备力直到回合结束时上升这个效果破坏的怪兽的原本数值。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71133680,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,71133680)
	-- 设置效果在伤害步骤中仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c71133680.atkcost)
	e1:SetTarget(c71133680.atktg)
	e1:SetOperation(c71133680.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e2:SetDescription(aux.Stringid(71133680,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,71133681)
	e2:SetCondition(c71133680.drcon)
	e2:SetTarget(c71133680.drtg)
	e2:SetOperation(c71133680.drop)
	c:RegisterEffect(e2)
end
-- 效果①的COST判定与执行：检查并把这张卡从手卡丢弃
function c71133680.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动成本（COST）从手卡丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己场上表侧表示的水属性怪兽，且存在除该怪兽及手卡中的这张卡以外的、可作为破坏对象的水属性怪兽
function c71133680.atkfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
		-- 检查自己手卡·场上是否存在至少1只除作为对象的怪兽及手卡中的这张卡以外的、满足破坏条件的水属性怪兽
		and Duel.IsExistingMatchingCard(c71133680.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,Group.FromCards(c,e:GetHandler()))
end
-- 过滤条件：用于破坏的水属性怪兽，且其原本攻击力或原本守备力大于0
function c71133680.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:GetBaseAttack()>0 or c:GetBaseDefense()>0)
end
-- 效果①的发动准备：选择自己场上1只表侧表示的水属性怪兽作为对象，并设置破坏操作信息
function c71133680.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c71133680.atkfilter(chkc,e,tp) end
	-- 检查自己场上是否存在符合条件的可作为对象的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c71133680.atkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的水属性怪兽作为效果对象
	Duel.SelectTarget(tp,c71133680.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为：从手卡或场上破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- 效果①的效果处理：选那只怪兽以外的自己的手卡·场上1只水属性怪兽破坏，作为对象的怪兽的攻击力·守备力直到回合结束时上升被破坏怪兽的原本数值
function c71133680.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从手卡·场上选择1只除对象怪兽以外的水属性怪兽
	local dc=Duel.SelectMatchingCard(tp,c71133680.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,tc):GetFirst()
	-- 若成功破坏选中的怪兽，则继续处理后续效果
	if dc and Duel.Destroy(dc,REASON_EFFECT)~=0 then
		if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
		local atk=dc:GetBaseAttack()
		local def=dc:GetBaseDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 作为对象的怪兽的攻击力·守备力直到回合结束时上升这个效果破坏的怪兽的原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		tc:RegisterEffect(e2)
	end
end
-- 效果②的发动条件：这张卡从场上送去墓地的场合
function c71133680.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的发动准备：检查是否可以抽卡，并设置抽卡和丢弃手卡的操作信息
function c71133680.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以进行抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理：自己从卡组抽1张，那之后选1张手卡丢弃
function c71133680.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试让玩家从卡组抽1张卡，并检查是否成功抽卡
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的丢弃手卡处理与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 让玩家选择1张手卡丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
