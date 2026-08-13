--肆世壊からの天跨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力·守备力上升那只对方怪兽的攻击力和守备力之内较高方的数值。
-- ●自己场上的「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象的效果发动时才能发动。那个效果无效。
function c41619242.initial_effect(c)
	-- 将卡号56099748（维萨斯-斯塔弗罗斯特）加入这张卡的代码列表，使其他卡能识别这张卡上记载了该卡名。
	aux.AddCodeList(c,56099748)
	-- 以自己场上1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力·守备力上升那只对方怪兽的攻击力和守备力之内较高方的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41619242,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,41619242+EFFECT_COUNT_CODE_OATH)
	-- 设置e1只能在伤害步骤的伤害计算前（或非伤害步骤）发动，不能在伤害计算时发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c41619242.atktg)
	e1:SetOperation(c41619242.atkop)
	c:RegisterEffect(e1)
	-- 自己场上的「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象的效果发动时才能发动。那个效果无效。
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
-- 过滤出表侧表示且属于「恐吓爪牙族」怪兽或「维萨斯-斯塔弗罗斯特」的自己场上怪兽，作为第一个效果可选的自己方对象。
function c41619242.atkfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x17a) or c:IsCode(56099748))
end
-- 过滤出表侧表示且攻击力或守备力大于0的对方怪兽，作为第一个效果可选的对方对象。
function c41619242.atkfilter2(c)
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
-- 第一个效果的发动时点及目标选择函数：检查是否存在合法对象，并让玩家选择自己场上1只符合条件的怪兽和对方场上1只符合条件的怪兽作为效果对象。
function c41619242.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 合法性检查前半：确认自己场上存在至少1只表侧表示且符合「恐吓爪牙族」或「维萨斯-斯塔弗罗斯特」的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c41619242.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 合法性检查后半：同时确认对方场上存在至少1只表侧表示且攻击力或守备力大于0的怪兽。
		and Duel.IsExistingTarget(c41619242.atkfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示己方发动了「攻守上升」这个效果（显示对应的效果描述文字）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向当前玩家弹出选择提示，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合atkfilter条件的怪兽，并将其登记为效果对象。
	local g1=Duel.SelectTarget(tp,c41619242.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向当前玩家弹出选择提示，要求选择效果的对象（第二次选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择1只符合atkfilter2条件的表侧表示怪兽，并将其登记为效果对象。
	local g2=Duel.SelectTarget(tp,c41619242.atkfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
end
-- 第一个效果处理：从连锁信息中取出对象组，过滤出仍与效果有关的卡；若不足2张则终止；再分别取出自己怪兽和对方怪兽，给自己怪兽赋予攻击力、守备力上升（上升值为对方怪兽攻击力与守备力中较高方的数值）。
function c41619242.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡片组（包含发动时选择的自己和对方怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<2 then return end
	local sc1=tg:Filter(Card.IsControler,nil,tp):GetFirst()
	local sc2=tg:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if not sc1 or not sc2 then return end
	-- 那只自己怪兽的攻击力·守备力上升那只对方怪兽的攻击力和守备力之内较高方的数值。
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
-- 过滤出位于怪兽区、表侧表示、控制者为tp且属于「恐吓爪牙族」或「维萨斯-斯塔弗罗斯特」的卡，用于判断被连锁效果的对象是否满足条件。
function c41619242.disfilter(c,tp)
	return (c:IsSetCard(0x17a) or c:IsCode(56099748))
		and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp)
end
-- 第二个效果的发动条件：被连锁的效果是取对象效果，且其对象中包含自己场上符合disfilter条件的怪兽，并且该连锁效果能被无效。
function c41619242.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取被连锁的效果（连锁编号ev）所选择的对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象卡组存在且含有符合disfilter条件的卡，并且该连锁效果可以被无效，则允许发动第二个效果。
	return g and g:IsExists(c41619242.disfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 第二个效果的target函数：功能仅返回true（合法性已由condition把关），向对方提示发动选择，并把操作信息登记为无效效果（目标是当前发动效果的卡）。
function c41619242.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示己方发动了「效果无效」这个效果（显示对应的效果描述文字）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次连锁的处理信息为：无效效果，对象为当前发动的效果所属的卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 第二个效果处理：直接无效对方发动的那个连锁效果。
function c41619242.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 让连锁编号为ev的效果无效。
	Duel.NegateEffect(ev)
end
