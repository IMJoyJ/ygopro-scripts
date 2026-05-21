--またたびキャット
-- 效果：
-- 自己场上有这张卡以外的兽族怪兽存在的场合，不能攻击这张卡。把对方场上存在的1只怪兽守备力在回合结束前变为0。这个效果1回合只能使用1次。
function c96501677.initial_effect(c)
	-- 自己场上有这张卡以外的兽族怪兽存在的场合，不能攻击这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c96501677.ccon)
	-- 设置不能成为攻击对象效果的过滤函数，防止因免疫效果而失效
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 把对方场上存在的1只怪兽守备力在回合结束前变为0。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96501677,0))  --"守备变化"
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c96501677.deftg)
	e2:SetOperation(c96501677.defop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的兽族怪兽
function c96501677.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 不能成为攻击对象效果的发动条件判定函数
function c96501677.ccon(e)
	-- 检查自己场上是否存在除自身以外的表侧表示兽族怪兽
	return Duel.IsExistingMatchingCard(c96501677.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 守备力变为0效果的发动准备与对象选择函数
function c96501677.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时的对象合法性检查，判定该卡是否仍为对方场上守备力不为0的怪兽
	if chkc then return aux.nzdef(chkc) and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 效果发动时的可行性检查，判定对方场上是否存在守备力不为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzdef,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只守备力不为0的怪兽作为效果对象
	Duel.SelectTarget(tp,aux.nzdef,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 守备力变为0效果的实际执行函数
function c96501677.defop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 守备力在回合结束前变为0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
