--虹光の宣告者
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：只要这张卡在怪兽区域存在，从双方的手卡·卡组送去墓地的怪兽不去墓地而除外。
-- ②：怪兽的效果·魔法·陷阱卡发动时，把这张卡解放才能发动。那个发动无效并破坏。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只仪式怪兽或者1张仪式魔法卡加入手卡。
function c79606837.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，从双方的手卡·卡组送去墓地的怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c79606837.rmtarget)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_DECK,LOCATION_HAND+LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- ②：怪兽的效果·魔法·陷阱卡发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79606837,0))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c79606837.discon)
	e2:SetCost(c79606837.discost)
	e2:SetTarget(c79606837.distg)
	e2:SetOperation(c79606837.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只仪式怪兽或者1张仪式魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79606837,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(c79606837.thtg)
	e3:SetOperation(c79606837.thop)
	c:RegisterEffect(e3)
end
-- 过滤送去墓地的卡片，确定其是否为怪兽卡
function c79606837.rmtarget(e,c)
	return c:IsType(TYPE_MONSTER)
end
-- 检查发动无效效果的发动条件：此卡未在战斗中被破坏，且被连锁的效果是怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
function c79606837.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查被连锁的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 检查并执行发动无效效果的消耗：解放自身
function c79606837.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检查并设置发动无效效果的目标信息：无效该发动，若该卡可破坏且仍存在则将其破坏
function c79606837.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行发动无效效果的处理：使该发动无效，并将其破坏
function c79606837.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡仍与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤卡组中可以加入手牌的仪式怪兽或仪式魔法卡
function c79606837.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 检查并设置检索效果的目标信息：从卡组将1张仪式卡加入手牌
function c79606837.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查卡组中是否存在至少1张满足条件的仪式卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79606837.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的处理：让玩家从卡组选择1张仪式卡加入手牌并给对方确认
function c79606837.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的仪式卡
	local g=Duel.SelectMatchingCard(tp,c79606837.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
