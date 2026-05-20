--LL－リサイト・スターリング
-- 效果：
-- 1星怪兽×2只以上
-- ①：这张卡超量召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力上升这张卡的超量素材数量×300。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只鸟兽族·1星怪兽加入手卡。
-- ③：超量召唤的这张卡的战斗发生的对自己的战斗伤害让对方也承受。
function c8491961.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：1星怪兽2只以上
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡超量召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力上升这张卡的超量素材数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8491961,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c8491961.atkcon)
	e1:SetTarget(c8491961.atktg)
	e1:SetOperation(c8491961.atkop)
	c:RegisterEffect(e1)
	-- ③：超量召唤的这张卡的战斗发生的对自己的战斗伤害让对方也承受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
	e2:SetCondition(c8491961.damcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只鸟兽族·1星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8491961,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c8491961.thcost)
	e3:SetTarget(c8491961.thtg)
	e3:SetOperation(c8491961.thop)
	c:RegisterEffect(e3)
end
-- 发动条件：这张卡是超量召唤成功，且自身拥有超量素材
function c8491961.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
		and e:GetHandler():GetOverlayCount()>0
end
-- 效果①的目标选择与判定
function c8491961.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判定场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的执行：使目标怪兽的攻击力·守备力上升自身超量素材数量×300
function c8491961.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local oc=c:GetOverlayCount()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and oc>0 then
		-- 那只怪兽的攻击力上升这张卡的超量素材数量×300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(300*oc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 效果③的适用条件：这张卡是超量召唤成功的状态
function c8491961.damcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果②的费用：取除这张卡的1个超量素材
function c8491961.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：1星的鸟兽族怪兽且能加入手卡
function c8491961.thfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 效果②的目标判定与操作信息设置
function c8491961.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8491961.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行：从卡组选择1只满足条件的怪兽加入手卡并给对方确认
function c8491961.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c8491961.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
