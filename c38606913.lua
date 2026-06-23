--方界縁起
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把最多有自己场上的「方界」怪兽数量的方界指示物给对方场上的表侧表示怪兽放置。有方界指示物放置的怪兽不能攻击，效果无效化。
-- ②：把墓地的这张卡除外，以自己场上1只「方界」怪兽为对象才能发动。这个回合，每次那只怪兽战斗破坏有方界指示物放置的怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
function c38606913.initial_effect(c)
	-- ①：把最多有自己场上的「方界」怪兽数量的方界指示物给对方场上的表侧表示怪兽放置。有方界指示物放置的怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38606913,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,38606913)
	e1:SetTarget(c38606913.target)
	e1:SetOperation(c38606913.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「方界」怪兽为对象才能发动。这个回合，每次那只怪兽战斗破坏有方界指示物放置的怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38606914)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38606913.damtg)
	e2:SetOperation(c38606913.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为表侧表示的「方界」怪兽
function c38606913.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
-- 效果的target阶段，检查自己场上是否存在至少1只表侧表示的「方界」怪兽，以及对方场上是否存在至少1只表侧表示的怪兽
function c38606913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「方界」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38606913.ctfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果的activate阶段，检索满足条件的卡片组并放置方界指示物，同时为被放置指示物的怪兽添加不能攻击和效果无效化的永续效果
function c38606913.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上表侧表示的「方界」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c38606913.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 获取对方场上表侧表示的怪兽数量
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1038,1)
		-- 为被放置指示物的怪兽添加不能攻击的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c38606913.condition)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
	end
end
-- 条件函数，判断该怪兽是否拥有方界指示物
function c38606913.condition(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 过滤函数，用于判断是否为表侧表示的「方界」怪兽
function c38606913.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER)
end
-- 效果的target阶段，选择自己场上1只表侧表示的「方界」怪兽作为对象
function c38606913.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38606913.damfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的「方界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c38606913.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「方界」怪兽作为对象
	Duel.SelectTarget(tp,c38606913.damfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果的operation阶段，为被选择的「方界」怪兽注册战斗破坏时触发的伤害效果
function c38606913.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为被选择的「方界」怪兽注册EVENT_LEAVE_FIELD_P时点效果，用于记录被破坏怪兽的方界指示物数量
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD_P)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c38606913.regop)
		tc:RegisterEffect(e1)
		-- 为被选择的「方界」怪兽注册EVENT_BATTLE_DESTROYING时点效果，用于在战斗破坏对方怪兽时造成伤害
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetOperation(c38606913.damop2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+EVENT_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(38606913,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- EVENT_LEAVE_FIELD_P时点效果的处理函数，记录被破坏怪兽的方界指示物数量
function c38606913.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	local ct=c:GetCounter(0x1038)
	e:SetLabel(ct)
end
-- EVENT_BATTLE_DESTROYING时点效果的处理函数，计算并造成伤害
function c38606913.damop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	local ct=e:GetLabelObject():GetLabel()
	if c:GetFlagEffect(38606913)>0 and ct>0 then
		local atk=tc:GetBaseAttack()
		-- 以破坏怪兽的原本攻击力为基准，给与对方玩家伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
