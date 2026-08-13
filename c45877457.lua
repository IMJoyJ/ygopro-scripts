--魔鍵砲－ガレスヴェート
-- 效果：
-- 「魔键-马夫提亚」降临。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升自己墓地的怪兽的属性种类×300。
-- ②：这张卡的仪式召唤使用的怪兽的属性是2种类以上的场合，持有和自己墓地的其中任意种的怪兽相同属性的怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
-- ③：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只「魔键」怪兽加入手卡。
function c45877457.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡的仪式召唤使用的怪兽的属性是2种类以上的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c45877457.valcheck)
	c:RegisterEffect(e0)
	-- 这张卡的攻击力上升自己墓地的怪兽的属性种类×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c45877457.atkval)
	c:RegisterEffect(e1)
	-- 持有和自己墓地的其中任意种的怪兽相同属性的怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
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
	-- 这张卡的仪式召唤使用的怪兽的属性是2种类以上的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c45877457.matcon)
	e3:SetOperation(c45877457.matop)
	c:RegisterEffect(e3)
	e0:SetLabelObject(e3)
	-- 仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只「魔键」怪兽加入手卡。
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
-- 计算自己墓地中怪兽的属性种类数并乘以300，作为这张卡的攻击力上升数值。
function c45877457.atkval(e,c)
	-- 获取控制者墓地中的所有怪兽卡。
	local g=Duel.GetMatchingGroup(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)*300
end
-- 判断这张卡是否通过仪式召唤成功，且仪式召唤使用的素材中有2种类以上的属性（e0记录的label为1）。
function c45877457.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 在这张卡上设置一个标记（45877457），表示其仪式召唤使用的怪兽属性为2种类以上，并带有客户端提示。
function c45877457.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(45877457,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(45877457,2))  --"仪式召唤使用的怪兽的属性是2种类以上"
end
-- 过滤函数：筛选具有属性（属性值大于0）的怪兽。
function c45877457.attfilter(c)
	return c:GetAttribute()>0
end
-- 检查仪式召唤所用的素材怪兽中属性的种类数是否大于1，将结果写入e3的标签中（1为满足，0为不满足）。
function c45877457.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c45877457.attfilter,nil)
	if fg:GetClassCount(Card.GetAttribute)>1 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ②效果的发动条件：对方发动怪兽效果，该连锁可以被无效，此卡拥有素材属性2种类以上的标记，且自己墓地存在与对方发动效果的怪兽相同属性的怪兽。
function c45877457.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认发动者为对方、发动效果为怪兽效果、连锁可被无效、且此卡已取得素材属性2种类以上的标记。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and e:GetHandler():GetFlagEffect(45877457)>0
		-- 确认自己墓地存在至少1只与对方发动的怪兽效果相同属性的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,re:GetHandler():GetAttribute())
end
-- ②效果发动时，设置无效该发动以及破坏该效果的怪兽的操作信息。
function c45877457.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将拟无效的连锁（eg）标记为无效类别。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动效果的怪兽仍与效果关联，则设置操作信息：将其标记为破坏对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：使对方发动的效果无效，并破坏发动效果的怪兽。
function c45877457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效对方连锁，且对方发动效果的怪兽仍与效果关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动效果的怪兽以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡是仪式召唤的怪兽，且从场上被送去墓地。
function c45877457.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：筛选卡组中卡名含「魔键」的怪兽卡，且能够加入手卡。
function c45877457.thfilter(c)
	return c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果发动时，确认卡组中存在符合条件的「魔键」怪兽，并设置检索到手的操作信息。
function c45877457.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查卡组是否存在1只符合条件的「魔键」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45877457.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡（检索效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只「魔键」怪兽加入手卡，并让对方确认。
function c45877457.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，要求选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「魔键」怪兽。
	local hg=Duel.SelectMatchingCard(tp,c45877457.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if hg:GetCount()>0 then
		-- 将选中的「魔键」怪兽加入手卡（效果处理）。
		Duel.SendtoHand(hg,tp,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,hg)
	end
end
