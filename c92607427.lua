--トイ・パレード
-- 效果：
-- 这个卡名在规则上也当作「魔玩具」卡使用。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以从额外卡组特殊召唤的1只自己的暗属性怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽每次战斗破坏怪兽送去墓地可以继续攻击。
-- ②：自己场上有天使族怪兽存在的场合，把墓地的这张卡除外才能发动。从自己墓地选1只4星以下的暗属性怪兽加入手卡。
function c92607427.initial_effect(c)
	-- ①：以从额外卡组特殊召唤的1只自己的暗属性怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽每次战斗破坏怪兽送去墓地可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92607427,0))  --"多次攻击"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92607427)
	e1:SetTarget(c92607427.target)
	e1:SetOperation(c92607427.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有天使族怪兽存在的场合，把墓地的这张卡除外才能发动。从自己墓地选1只4星以下的暗属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92607427,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,92607427)
	-- 把墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c92607427.thcon)
	e2:SetTarget(c92607427.thtg)
	e2:SetOperation(c92607427.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、从额外卡组特殊召唤的暗属性怪兽
function c92607427.filter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ①号效果的发动准备（检查并选择对象）
function c92607427.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92607427.filter(chkc) end
	-- 检查自己场上是否存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c92607427.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c92607427.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①号效果的处理（赋予不能攻击宣言的限制以及战斗破坏怪兽时可以继续攻击的效果）
function c92607427.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，自己不用那只怪兽不能攻击宣言
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c92607427.ftarget)
		e1:SetLabel(tc:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该回合自己不能用其他怪兽进行攻击宣言的全局效果
		Duel.RegisterEffect(e1,tp)
		-- 那只怪兽每次战斗破坏怪兽送去墓地可以继续攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetCondition(c92607427.atkcon)
		e2:SetOperation(c92607427.atkop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：除了作为对象的那只怪兽以外的怪兽
function c92607427.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 检查该怪兽是否战斗破坏了怪兽送去墓地，且当前可以进行追加攻击
function c92607427.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定该怪兽是否战斗破坏了怪兽送去墓地，且该怪兽目前可以进行追加攻击
	return aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable(0)
end
-- 战斗破坏怪兽送去墓地时，使该怪兽可以再进行1次攻击
function c92607427.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
-- 过滤条件：自己场上表侧表示的天使族怪兽
function c92607427.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- ②号效果的发动条件（自己场上有天使族怪兽存在）
function c92607427.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的天使族怪兽
	return Duel.IsExistingMatchingCard(c92607427.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己墓地4星以下的暗属性怪兽
function c92607427.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ②号效果的发动准备（检查墓地是否有符合条件的怪兽并设置操作信息）
function c92607427.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在4星以下的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92607427.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理的操作信息为“从墓地将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②号效果的处理（从墓地选1只4星以下的暗属性怪兽加入手卡）
function c92607427.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只不受墓地限制效果影响的、4星以下的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c92607427.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显式展示被选择的卡片
		Duel.HintSelection(g)
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
