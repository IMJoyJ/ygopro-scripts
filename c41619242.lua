--肆世壊からの天跨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力·守备力上升那只对方怪兽的攻击力和守备力之内较高方的数值。
-- ●自己场上的「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象的效果发动时才能发动。那个效果无效。
function c41619242.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与维萨斯-斯塔弗罗斯特（56099748）的关联
	aux.AddCodeList(c,56099748)
	-- ①：可以从以下效果选择1个发动。●以自己场上1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力·守备力上升那只对方怪兽的攻击力和守备力之内较高方的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41619242,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,41619242+EFFECT_COUNT_CODE_OATH)
	-- 设置效果发动条件为伤害步骤前，防止在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c41619242.atktg)
	e1:SetOperation(c41619242.atkop)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。●自己场上的「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象的效果发动时才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41619242,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,41619242+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c41619242.discon)
	e2:SetTarget(c41619242.distg)
	e2:SetOperation(c41619242.disop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示的恐吓爪牙族怪兽或维萨斯-斯塔弗罗斯特
function c41619242.atkfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x17a) or c:IsCode(56099748))
end
-- 筛选对方场上表侧表示且攻击力或守备力大于0的怪兽
function c41619242.atkfilter2(c)
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
-- 判断是否满足选择对象的条件，即自己场上存在恐吓爪牙族或维萨斯-斯塔弗罗斯特，对方场上存在表侧表示的怪兽
function c41619242.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上是否存在符合条件的恐吓爪牙族或维萨斯-斯塔弗罗斯特
	if chk==0 then return Duel.IsExistingTarget(c41619242.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在符合条件的表侧表示怪兽
		and Duel.IsExistingTarget(c41619242.atkfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方提示发动了“攻守上升”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的恐吓爪牙族或维萨斯-斯塔弗罗斯特作为对象
	local g1=Duel.SelectTarget(tp,c41619242.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上的表侧表示怪兽作为对象
	local g2=Duel.SelectTarget(tp,c41619242.atkfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
end
-- 处理“攻守上升”效果，将选中的自己怪兽的攻击力和守备力提升至对方怪兽攻击力和守备力的最大值
function c41619242.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<2 then return end
	local sc1=tg:Filter(Card.IsControler,nil,tp):GetFirst()
	local sc2=tg:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if not sc1 or not sc2 then return end
	-- 创建一个攻击力提升效果，提升值为对方怪兽攻击力和守备力的最大值
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(math.max(sc2:GetAttack(),sc2:GetDefense()))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	sc1:RegisterEffect(e2)
end
-- 筛选自己场上的恐吓爪牙族或维萨斯-斯塔弗罗斯特怪兽
function c41619242.disfilter(c,tp)
	return (c:IsSetCard(0x17a) or c:IsCode(56099748))
		and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp)
end
-- 判断连锁效果是否具有取对象属性，并检查对象中是否存在符合条件的自己场上的恐吓爪牙族或维萨斯-斯塔弗罗斯特怪兽
function c41619242.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁效果的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡片组中是否存在符合条件的自己场上的恐吓爪牙族或维萨斯-斯塔弗罗斯特怪兽，并判断该连锁是否可以被无效
	return g and g:IsExists(c41619242.disfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 设置“效果无效”效果的目标和操作信息
function c41619242.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示发动了“效果无效”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要使一个效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 处理“效果无效”效果，使连锁效果无效
function c41619242.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁效果无效
	Duel.NegateEffect(ev)
end
