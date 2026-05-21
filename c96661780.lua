--フォース・オブ・ガーディアン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己基本分比对方少的场合，以原本卡名包含「门之守护神」的自己场上1只怪兽为对象才能发动。对方基本分变成一半。那之后，作为对象的怪兽的攻击力上升对方基本分数值。
-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
function c96661780.initial_effect(c)
	-- 注册卡片效果中记载的「雷魔神-桑迦」、「风魔神-修迦」、「水魔神-斯迦」的卡片密码
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- ①：自己基本分比对方少的场合，以原本卡名包含「门之守护神」的自己场上1只怪兽为对象才能发动。对方基本分变成一半。那之后，作为对象的怪兽的攻击力上升对方基本分数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96661780,0))  --"对方基本分变成一半"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,96661780)
	e1:SetCondition(c96661780.condition)
	e1:SetTarget(c96661780.target)
	e1:SetOperation(c96661780.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96661780,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,96661781)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c96661780.thtg)
	e2:SetOperation(c96661780.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c96661780.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否比对方少
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 过滤原本卡名包含「门之守护神」且在场上表侧表示的怪兽
function c96661780.filter(c)
	return c:IsOriginalSetCard(0x1052) and c:IsFaceup()
end
-- 效果①的发动准备与对象选择
function c96661780.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c96661780.filter(chkc) end
	-- 检查自己场上是否存在符合条件的可选择对象
	if chk==0 then return Duel.IsExistingTarget(c96661780.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只原本卡名包含「门之守护神」的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c96661780.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理（对方基本分减半，之后对象怪兽攻击力上升对方基本分数值）
function c96661780.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方的基本分变成一半（向上取整）
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 中断效果处理，使后续的攻击力上升处理不与基本分减半同时处理
		Duel.BreakEffect()
		-- 作为对象的怪兽的攻击力上升对方基本分数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 设置攻击力上升的数值为当前的对方基本分数值
		e1:SetValue(Duel.GetLP(1-tp))
		tc:RegisterEffect(e1)
	end
end
-- 过滤卡组或除外状态中可以加入手卡的「雷魔神-桑迦」、「风魔神-修迦」或「水魔神-斯迦」
function c96661780.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877) and c:IsAbleToHand()
end
-- 效果②的发动准备与效果分类注册
function c96661780.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或除外状态中是否存在可以加入手卡的对应怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96661780.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁处理信息，表示该效果会将卡组或除外状态的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 效果②的效果处理（将对应的1只怪兽加入手卡）
function c96661780.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或除外状态中选择1只「雷魔神-桑迦」、「风魔神-修迦」或「水魔神-斯迦」
	local g=Duel.SelectMatchingCard(tp,c96661780.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
