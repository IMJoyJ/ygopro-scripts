--御巫の祓舞
-- 效果：
-- 「御巫」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽不会被效果破坏。
-- ②：对方场上有怪兽特殊召唤的场合，以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽回到手卡。
function c16433136.initial_effect(c)
	-- 「御巫」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c16433136.target)
	e1:SetOperation(c16433136.activate)
	c:RegisterEffect(e1)
	-- 「御巫」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c16433136.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方场上有怪兽特殊召唤的场合，以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16433136,0))  --"双方怪兽回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,16433136)
	e4:SetCondition(c16433136.thcon)
	e4:SetTarget(c16433136.thtg)
	e4:SetOperation(c16433136.thop)
	c:RegisterEffect(e4)
end
-- 筛选表侧表示的「御巫」系列怪兽，作为装备对象选择和装备限制的通用条件。
function c16433136.filter(c)
	return c:IsSetCard(0x18d) and c:IsFaceup()
end
-- 装备魔法的发动处理：从场上选择1只表侧表示的「御巫」怪兽作为装备对象，并设置将进行装备的操作信息。
function c16433136.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16433136.filter(chkc) end
	-- 发动条件判定：检查场上是否存在至少1只表侧表示的「御巫」怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c16433136.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 让玩家从场上选择1只表侧表示的「御巫」怪兽作为装备对象，同时将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c16433136.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本次连锁处理将进行装备魔法的装备操作（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备魔法发动后的处理：若此卡和对象卡仍与效果关联且对象表侧表示，则将此卡装备给对象怪兽。
function c16433136.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给对象怪兽，装备成功则持续适用装备效果。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 定义装备限制：只有卡名属于「御巫」系列的怪兽才能装备此卡。
function c16433136.eqlimit(e,c)
	return c:IsSetCard(0x18d)
end
-- ②效果的发动条件：特殊召唤成功的怪兽中存在由对方控制的怪兽（即对方场上有怪兽被特殊召唤）。
function c16433136.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- ②效果的发动时目标选择：分别从自己场上和对方场上各选1只可以被返回手卡的怪兽作为对象。
function c16433136.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性判定：自己场上是否存在至少1只可以被返回手卡的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,nil)
		-- 同时对方场上也存在至少1只可以被返回手卡的怪兽，双方场上的条件均满足才能发动。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，引导玩家选择自己要返回手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1只可返回手卡的怪兽，并将其登记为本连锁的对象。
	local g1=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示选择提示，引导玩家选择对方场上要返回手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1只可返回手卡的怪兽，并将其登记为本连锁的对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本次连锁将把选择的对象怪兽（共2只）返回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果的实际处理：将仍与效果关联的对象怪兽全部返回持有者手卡。
function c16433136.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组，并过滤出仍然与效果相关的对象（排除已离场或对象被重置的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后的对象怪兽以效果原因送去其持有者的手卡，即返回手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
