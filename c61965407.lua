--遡洸する煉獄
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方准备阶段，以自己墓地1只「狱火机」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己准备阶段，以自己的除外状态的1只「狱火机」怪兽为对象才能发动。那只怪兽回到墓地。
-- ③：自己场上有「狱火机」怪兽以外的怪兽存在的场合这张卡送去墓地。
function c61965407.initial_effect(c)
	-- 开启全局标记：不入连锁的自我送墓检查（用于处理EFFECT_SELF_TOGRAVE效果）
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方准备阶段，以自己墓地1只「狱火机」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,61965407)
	e2:SetCondition(c61965407.thcon)
	e2:SetTarget(c61965407.thtg)
	e2:SetOperation(c61965407.thop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段，以自己的除外状态的1只「狱火机」怪兽为对象才能发动。那只怪兽回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,61965408)
	e3:SetCondition(c61965407.tgcon)
	e3:SetTarget(c61965407.tgtg)
	e3:SetOperation(c61965407.tgop)
	c:RegisterEffect(e3)
	-- ③：自己场上有「狱火机」怪兽以外的怪兽存在的场合这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_TOGRAVE)
	e4:SetCondition(c61965407.sdcon)
	c:RegisterEffect(e4)
end
-- 效果①（回收墓地怪兽）的发动条件函数
function c61965407.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方（即对方回合的准备阶段）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：自己墓地的「狱火机」怪兽且能加入手卡
function c61965407.thfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①（回收墓地怪兽）的发动目标选择与检测函数
function c61965407.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61965407.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的「狱火机」怪兽
	if chk==0 then return Duel.IsExistingTarget(c61965407.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「狱火机」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61965407.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①（回收墓地怪兽）的效果处理函数
function c61965407.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 效果②（除外怪兽回墓）的发动条件函数
function c61965407.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己（即自己回合的准备阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：自己除外状态的表侧表示「狱火机」怪兽
function c61965407.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER)
end
-- 效果②（除外怪兽回墓）的发动目标选择与检测函数
function c61965407.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c61965407.tgfilter(chkc) end
	-- 检查自己除外状态的卡中是否存在至少1只满足条件的「狱火机」怪兽
	if chk==0 then return Duel.IsExistingTarget(c61965407.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己除外状态的1只「狱火机」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61965407.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②（除外怪兽回墓）的效果处理函数
function c61965407.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
-- 过滤条件：里侧表示怪兽，或者不是「狱火机」怪兽的怪兽
function c61965407.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xbb)
end
-- 效果③（自我送墓）的触发条件函数
function c61965407.sdcon(e)
	-- 检查自己场上是否存在「狱火机」怪兽以外的怪兽（包括里侧表示怪兽和非「狱火机」怪兽）
	return Duel.IsExistingMatchingCard(c61965407.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
