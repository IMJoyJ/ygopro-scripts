--魔鍵砲－ガレスヴェート
-- 效果：
-- 「魔键-马夫提亚」降临。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升自己墓地的怪兽的属性种类×300。
-- ②：这张卡的仪式召唤使用的怪兽的属性是2种类以上的场合，持有和自己墓地的其中任意种的怪兽相同属性的怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
-- ③：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只「魔键」怪兽加入手卡。
function c45877457.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：「魔键-马夫提亚」降临。这个卡名的②③的效果1回合各能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c45877457.valcheck)
	c:RegisterEffect(e0)
	-- 效果原文内容：①：这张卡的攻击力上升自己墓地的怪兽的属性种类×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c45877457.atkval)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的仪式召唤使用的怪兽的属性是2种类以上的场合，持有和自己墓地的其中任意种的怪兽相同属性的怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45877457,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,45877457)
	e2:SetCondition(c45877457.condition)
	e2:SetTarget(c45877457.target)
	e2:SetOperation(c45877457.activate)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只「魔键」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c45877457.matcon)
	e3:SetOperation(c45877457.matop)
	c:RegisterEffect(e3)
	e0:SetLabelObject(e3)
	-- 规则层面操作：检索满足条件的卡片组
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(45877457,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,45877458)
	e4:SetCondition(c45877457.thcon)
	e4:SetTarget(c45877457.thtg)
	e4:SetOperation(c45877457.thop)
	c:RegisterEffect(e4)
end
-- 规则层面操作：计算墓地中怪兽的属性种类数并乘以300作为攻击力
function c45877457.atkval(e,c)
	-- 规则层面操作：获取玩家墓地中所有怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)*300
end
-- 规则层面操作：判断此卡是否为仪式召唤成功且标记为属性种类大于1
function c45877457.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 规则层面操作：为该卡注册一个FlagEffect，用于标记仪式召唤使用的怪兽属性种类大于1
function c45877457.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(45877457,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(45877457,2))  --"仪式召唤使用的怪兽的属性是2种类以上"
end
-- 规则层面操作：过滤出具有属性的怪兽
function c45877457.attfilter(c)
	return c:GetAttribute()>0
end
-- 规则层面操作：检查仪式召唤使用的怪兽属性种类是否大于1
function c45877457.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c45877457.attfilter,nil)
	if fg:GetClassCount(Card.GetAttribute)>1 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 规则层面操作：判断是否为对方发动的怪兽效果且可无效
function c45877457.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否为对方发动的怪兽效果且可无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and e:GetHandler():GetFlagEffect(45877457)>0
		-- 规则层面操作：检查玩家墓地中是否存在与该效果属性相同的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,re:GetHandler():GetAttribute())
end
-- 规则层面操作：设置连锁处理信息，包括无效和破坏
function c45877457.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置连锁处理信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：设置连锁处理信息，表示将破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面操作：使连锁发动无效并破坏目标怪兽
function c45877457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：使连锁发动无效并破坏目标怪兽
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 规则层面操作：判断此卡是否为仪式召唤且从主要怪兽区被送去墓地
function c45877457.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 规则层面操作：过滤出「魔键」怪兽
function c45877457.thfilter(c)
	return c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面操作：设置连锁处理信息，表示将把怪兽加入手牌
function c45877457.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45877457.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁处理信息，表示将把怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：选择并把怪兽加入手牌
function c45877457.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择满足条件的怪兽
	local hg=Duel.SelectMatchingCard(tp,c45877457.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if hg:GetCount()>0 then
		-- 规则层面操作：把怪兽加入手牌
		Duel.SendtoHand(hg,tp,REASON_EFFECT)
		-- 规则层面操作：确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,hg)
	end
end
