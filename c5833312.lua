--デュエル・アカデミア
-- 效果：
-- ①：得到场上的怪兽种族的以下效果。
-- ●战士族·兽族·炎族：1回合1次，自己把陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ●恐龙族·海龙族·雷族：1回合1次，自己把魔法卡发动的场合才能发动。给与对方1000伤害。
-- ●机械族·天使族·恶魔族：1回合1次，自己把怪兽的效果发动的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升1000。
function c5833312.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●战士族·兽族·炎族：1回合1次，自己把陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5833312,0))  --"对应陷阱发动：卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c5833312.descon)
	e2:SetTarget(c5833312.destg)
	e2:SetOperation(c5833312.desop)
	c:RegisterEffect(e2)
	-- ●恐龙族·海龙族·雷族：1回合1次，自己把魔法卡发动的场合才能发动。给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5833312,1))  --"对应魔法发动：1000伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetCondition(c5833312.damcon)
	e3:SetTarget(c5833312.damtg)
	e3:SetOperation(c5833312.damop)
	c:RegisterEffect(e3)
	-- ●机械族·天使族·恶魔族：1回合1次，自己把怪兽的效果发动的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升1000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5833312,2))  --"对应怪兽发动：攻击力上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c5833312.atkcon)
	e4:SetTarget(c5833312.atktg)
	e4:SetOperation(c5833312.atkop)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示的战士族、兽族、炎族怪兽
function c5833312.filter1(c)
	return c:IsRace(RACE_WARRIOR+RACE_BEAST+RACE_PYRO) and c:IsFaceup()
end
-- 检查场上是否存在表侧表示的战士族/兽族/炎族怪兽，且自己发动了陷阱卡
function c5833312.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只表侧表示的战士族、兽族或炎族怪兽
	return Duel.IsExistingMatchingCard(c5833312.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and rp==tp
end
-- 破坏效果的发动准备，确认对方场上存在可选择的卡，并进行取对象和设置操作信息
function c5833312.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示当前玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理，获取对象卡并将其破坏
function c5833312.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的恐龙族、海龙族、雷族怪兽
function c5833312.filter2(c)
	return c:IsRace(RACE_DINOSAUR+RACE_SEASERPENT+RACE_THUNDER) and c:IsFaceup()
end
-- 检查场上是否存在表侧表示的恐龙族/海龙族/雷族怪兽，且自己发动了魔法卡
function c5833312.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只表侧表示的恐龙族、海龙族或雷族怪兽
	return Duel.IsExistingMatchingCard(c5833312.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and rp==tp
end
-- 伤害效果的发动准备，设置目标玩家、伤害数值及操作信息
function c5833312.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将效果的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的目标参数（伤害数值）设置为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的处理，获取目标玩家和伤害数值并给予伤害
function c5833312.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤场上表侧表示的机械族、天使族、恶魔族怪兽
function c5833312.filter3(c)
	return c:IsRace(RACE_MACHINE+RACE_FAIRY+RACE_FIEND) and c:IsFaceup()
end
-- 检查场上是否存在表侧表示的机械族/天使族/恶魔族怪兽，且自己发动了怪兽的效果
function c5833312.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只表侧表示的机械族、天使族或恶魔族怪兽
	return Duel.IsExistingMatchingCard(c5833312.filter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and re:IsActiveType(TYPE_MONSTER) and rp==tp
end
-- 攻击力上升效果的发动准备，确认自己场上存在表侧表示怪兽，并进行取对象操作
function c5833312.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示当前玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 攻击力上升效果的处理，获取对象怪兽并使其攻击力上升1000
function c5833312.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
