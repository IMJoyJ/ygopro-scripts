--魔降雷
-- 效果：
-- 这个卡名在规则上也当作「恶魔」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「恶魔」怪兽为对象才能发动。那只怪兽的攻击力上升600。那之后，可以把持有比那只怪兽的攻击力低的原本攻击力的对方场上的怪兽全部破坏。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只攻击力2500的恶魔族·6星怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册①效果（魔陷发动、取对象、改变攻击力并可能破坏怪兽，1回合1次）和②效果（墓地发动的起动效果，把墓地的恶魔族·6星·攻击力2500怪兽加入手卡，1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：以自己场上1只「恶魔」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段把墓地的这张卡除外，以自己墓地1只攻击力2500的恶魔族·6星怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 把墓地的这张卡除外作为发动代价（cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡是表侧表示的「恶魔」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- ①效果的目标选择：以自己场上1只表侧表示的「恶魔」怪兽为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动条件检查：确认自己场上存在至少1只可以成为对象的表侧表示「恶魔」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「恶魔」怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤函数：检查怪兽是表侧表示且原本攻击力低于指定数值（即持有比对象怪兽攻击力低的原本攻击力）
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk
end
-- ①效果的处理：令对象怪兽的攻击力上升600，然后可以让玩家选择是否把持有比那只怪兽攻击力低的原本攻击力的对方场上的怪兽全部破坏
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 立刻刷新场地信息，使攻击力上升立即生效
		Duel.AdjustAll()
		local atk=tc:GetAttack()
		-- 检查对象怪兽不受攻守反转类效果影响，且对方场上存在原本攻击力低于其攻击力的怪兽
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)
			-- 询问玩家是否把怪兽破坏（可选处理）
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
			-- 中断当前效果处理，使之后的破坏视为不同时处理（避免错时点）
			Duel.BreakEffect()
			-- 检索对方场上所有持有比对象怪兽攻击力低的原本攻击力的表侧表示怪兽
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
			-- 将这些怪兽全部因效果破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 过滤函数：检查卡是攻击力2500的恶魔族·6星怪兽且可以加入手卡
function s.thfilter(c)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsAbleToHand()
end
-- ②效果的目标选择：以自己墓地1只攻击力2500的恶魔族·6星怪兽为对象，并设置回手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动条件检查：确认自己墓地存在至少1只可以成为对象的攻击力2500的恶魔族·6星怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只攻击力2500的恶魔族·6星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息：将1张卡加入手卡（用于王家长眠之谷等效果的检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：对象怪兽不受王家长眠之谷影响时，将其加入手卡并展示给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与连锁相关且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 那只怪兽加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
	end
end
