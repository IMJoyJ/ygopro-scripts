--肆世壊の牙掌突
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以自己场上1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象才能发动。这个回合，那只怪兽可以用表侧守备表示的状态作出攻击。那个场合，攻击力和守备力之内较高方的数值适用进行伤害计算。
-- ②：额外怪兽区域有自己的「恐吓爪牙族」怪兽存在，对方把效果发动时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那个效果无效。
function c79552283.initial_effect(c)
	-- 在卡片中注册其记有「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象才能发动。这个回合，那只怪兽可以用表侧守备表示的状态作出攻击。那个场合，攻击力和守备力之内较高方的数值适用进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79552283,0))  --"守备表示攻击"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c79552283.adatktg)
	e2:SetOperation(c79552283.adatkop)
	c:RegisterEffect(e2)
	-- ②：额外怪兽区域有自己的「恐吓爪牙族」怪兽存在，对方把效果发动时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79552283,1))  --"对方效果无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,79552283)
	e4:SetCondition(c79552283.discon)
	e4:SetCost(c79552283.discost)
	e4:SetTarget(c79552283.distg)
	e4:SetOperation(c79552283.disop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示、非连接怪兽的「恐吓爪牙族」怪兽或「维萨斯-斯塔弗罗斯特」
function c79552283.filter(c,e,tp)
	return (c:IsSetCard(0x17a) or c:IsCode(56099748)) and c:IsFaceup() and not c:IsType(TYPE_LINK)
end
-- 效果①的发动准备与目标选择
function c79552283.adatktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c79552283.filter(chkc,e,tp) end
	-- 检查当前是否为自己的回合，且处于可以进行战斗相关操作的时点或阶段
	if chk==0 then return Duel.GetTurnPlayer()==tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 检查自己场上是否存在可以作为效果对象的合法怪兽
		and Duel.IsExistingTarget(c79552283.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c79552283.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
-- 效果①的效果处理：使目标怪兽可以用表侧守备表示进行攻击，并适用较高的攻防数值进行伤害计算
function c79552283.adatkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 这个回合，那只怪兽可以用表侧守备表示的状态作出攻击。那个场合，攻击力和守备力之内较高方的数值适用进行伤害计算。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(c79552283.adaval)
	tc:RegisterEffect(e1)
end
-- 比较怪兽的攻击力与守备力，返回较大值适用进行伤害计算（0代表适用攻击力，1代表适用守备力）
function c79552283.adaval(e)
	local c=e:GetHandler()
	return c:GetAttack()>c:GetDefense() and 0 or 1
end
-- 过滤自己额外怪兽区域表侧表示的「恐吓爪牙族」怪兽
function c79552283.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17a) and c:GetSequence()>=5
end
-- 效果②的发动条件判断
function c79552283.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方发动的效果是否可以被无效，且自己额外怪兽区域有「恐吓爪牙族」怪兽存在
	return Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(c79552283.exfilter,tp,LOCATION_MZONE,0,1,nil) and rp==1-tp
end
-- 效果②的发动代价处理
function c79552283.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将魔法与陷阱区域表侧表示的这张卡送去墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果②的发动准备与效果分类设置
function c79552283.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为“使该连锁的效果无效”
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果②的效果处理
function c79552283.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该对方发动的效果无效
	Duel.NegateEffect(ev)
end
