--熟練の栗魔導士
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：可以把这张卡1个魔力指示物取除，从以下效果选择1个发动。
-- ●这张卡的等级上升1星，攻击力上升1500。
-- ●从自己的卡组·墓地选1只「栗子球」怪兽或者1张「增殖」加入手卡。
function c88232397.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置效果处理为：在连锁发生时记录这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c88232397.acop)
	c:RegisterEffect(e1)
	-- ②：可以把这张卡1个魔力指示物取除，从以下效果选择1个发动。●这张卡的等级上升1星，攻击力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88232397,0))  --"等级和攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88232397)
	e2:SetCost(c88232397.cost)
	e2:SetOperation(c88232397.atkop)
	c:RegisterEffect(e2)
	-- ②：可以把这张卡1个魔力指示物取除，从以下效果选择1个发动。●从自己的卡组·墓地选1只「栗子球」怪兽或者1张「增殖」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88232397,1))  --"「栗子球」怪兽或者「增殖」加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,88232397)
	e3:SetCost(c88232397.cost)
	e3:SetTarget(c88232397.thtg)
	e3:SetOperation(c88232397.thop)
	c:RegisterEffect(e3)
end
-- 魔法卡发动连锁处理完毕时，若这张卡在连锁发生时已在场，则给这张卡放置1个魔力指示物
function c88232397.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 效果发动的代价：取除这张卡的1个魔力指示物，并向对方玩家提示选择发动的效果
function c88232397.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
	-- 向对方玩家提示当前选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 提升等级与攻击力效果的处理：使这张卡的等级上升1星，攻击力上升1500
function c88232397.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 攻击力上升1500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 这张卡的等级上升1星
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
-- 过滤条件：卡组或墓地中可加入手卡的「栗子球」怪兽或者「增殖」
function c88232397.thfilter(c)
	return (c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) or c:IsCode(40703222)) and c:IsAbleToHand()
end
-- 检索/回收效果的靶向检测与操作信息设置
function c88232397.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c88232397.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息为：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索/回收效果的处理：从卡组或墓地选择1张满足条件的卡加入手卡，并给对方确认
function c88232397.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件且不受「王家长眠之谷」影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88232397.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
