--熱き決闘者たち
-- 效果：
-- ①：自己怪兽的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那次攻击无效，作为对象的卡破坏。
-- ②：只要这张卡在魔法与陷阱区域存在，双方1回合只能有1张魔法·陷阱卡从手卡盖放，从额外卡组特殊召唤的怪兽在那个回合不能攻击。
-- ③：自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，选自己墓地1只怪兽加入手卡。
function c88851326.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己怪兽的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那次攻击无效，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88851326,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c88851326.atkcon)
	e2:SetTarget(c88851326.atktg)
	e2:SetOperation(c88851326.atkop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，双方1回合只能有1张魔法·陷阱卡从手卡盖放
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_SSET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c88851326.setcon1)
	e3:SetTarget(c88851326.settg)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetTargetRange(0,1)
	e4:SetCondition(c88851326.setcon2)
	c:RegisterEffect(e4)
	-- 从额外卡组特殊召唤的怪兽在那个回合不能攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c88851326.attg)
	c:RegisterEffect(e5)
	-- ③：自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，选自己墓地1只怪兽加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(88851326,1))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PREDRAW)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c88851326.thcon)
	e6:SetTarget(c88851326.thtg)
	e6:SetOperation(c88851326.thop)
	c:RegisterEffect(e6)
	if not c88851326.global_check then
		c88851326.global_check=true
		-- ①：自己怪兽的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那次攻击无效，作为对象的卡破坏。②：只要这张卡在魔法与陷阱区域存在，双方1回合只能有1张魔法·陷阱卡从手卡盖放，从额外卡组特殊召唤的怪兽在那个回合不能攻击。③：自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，选自己墓地1只怪兽加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c88851326.checkop)
		-- 注册全局环境下的全局效果，用于记录玩家从手卡盖放魔陷的动作。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局盖放检测函数，若盖放的卡片原本在手卡，则为该玩家注册已盖放过的标记。
function c88851326.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_HAND) then
		-- 为盖放卡片的玩家注册一个回合内有效的标记，用于限制后续的盖放。
		Duel.RegisterFlagEffect(rp,88851326,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果①的条件分支：判断当前回合玩家是否为自己（即自己怪兽的攻击宣言时）。
function c88851326.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是发动效果的玩家。
	return Duel.GetTurnPlayer()==tp
end
-- 效果①的过滤条件：目标卡片必须是魔法或陷阱卡。
function c88851326.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的靶向/发动准备阶段：检测并选择对方场上的1张魔法·陷阱卡作为对象，并设置破坏操作信息。
function c88851326.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c88851326.atkfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c88851326.atkfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c88851326.atkfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理的操作信息，表示该效果包含破坏1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的执行阶段：尝试无效攻击，若成功且对象卡片仍合法，则将其破坏。
function c88851326.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 尝试无效当前的攻击，并判断对象卡片是否仍与此效果相关联。
	if Duel.NegateAttack() and tc:IsRelateToEffect(e) then
		-- 因效果将作为对象的卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②自己限制的条件分支：判断自己本回合是否已经进行过手卡盖放。
function c88851326.setcon1(e)
	-- 返回自己本回合是否已注册过手卡盖放的标记。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),88851326)>0
end
-- 效果②对方限制的条件分支：判断对方本回合是否已经进行过手卡盖放。
function c88851326.setcon2(e)
	-- 返回对方本回合是否已注册过手卡盖放的标记。
	return Duel.GetFlagEffect(1-e:GetHandlerPlayer(),88851326)>0
end
-- 效果②限制盖放的目标过滤：限制从手卡进行的盖放。
function c88851326.settg(e,c)
	return c:IsLocation(LOCATION_HAND)
end
-- 效果②限制攻击的目标过滤：筛选出本回合从额外卡组特殊召唤的怪兽。
function c88851326.attg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果③的条件分支：判断当前是否为自己的回合。
function c88851326.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是自己。
	return tp==Duel.GetTurnPlayer()
end
-- 效果③的过滤条件：目标卡片必须是墓地中的怪兽，且能加入手卡。
function c88851326.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的靶向/发动准备阶段：检测是否能进行通常抽卡且墓地有怪兽，并设置加入手卡的操作信息。
function c88851326.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能进行通常抽卡，且自己墓地是否存在可以加入手卡的怪兽。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c88851326.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果包含从墓地将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的执行阶段：放弃通常抽卡，选择自己墓地1只怪兽加入手卡。
function c88851326.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认玩家当前是否能进行通常抽卡，若不能则不处理。
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合抽卡阶段的通常抽卡。
	aux.GiveUpNormalDraw(e,tp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c88851326.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显式展示被选择的卡片给双方玩家。
		Duel.HintSelection(g)
		-- 因效果将选中的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
