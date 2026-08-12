--混沌の黒魔術師
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的回合的结束阶段，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡战斗破坏对方怪兽的伤害计算后发动。那只对方怪兽除外。
-- ③：表侧表示的这张卡从场上离开的场合除外。
function c40737112.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的回合的结束阶段，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40737112,0))  --"魔法回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40737112)
	e1:SetCost(c40737112.thcost)
	e1:SetTarget(c40737112.thtg)
	e1:SetOperation(c40737112.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的伤害计算后发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40737112,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c40737112.rmcon)
	e2:SetTarget(c40737112.rmtg)
	e2:SetOperation(c40737112.rmop)
	c:RegisterEffect(e2)
	-- 表侧表示的这张卡从场上离开的场合除外。
	aux.AddBanishRedirect(c)
	if not c40737112.global_check then
		c40737112.global_check=true
		-- 为全局注册一个用于记录召唤和特殊召唤的持续效果，用于判断是否为本回合召唤的卡片。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(40737112)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置该持续效果的处理函数为aux.sumreg，用于记录召唤状态。
		ge1:SetOperation(aux.sumreg)
		-- 将该效果注册到玩家0（即所有玩家）的全局环境中。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(40737112)
		-- 将克隆的效果注册到玩家0（即所有玩家）的全局环境中，用于处理特殊召唤成功事件。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果cost函数，检查是否拥有标记以发动效果，若满足则重置标记。
function c40737112.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(40737112)~=0 end
	e:GetHandler():ResetFlagEffect(40737112)
end
-- 检索过滤函数，用于筛选墓地中的魔法卡。
function c40737112.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果target函数，选择墓地中的魔法卡作为对象。
function c40737112.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40737112.thfilter(chkc) end
	-- 判断是否存在满足条件的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(c40737112.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡片。
	local g=Duel.SelectTarget(tp,c40737112.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将目标卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果operation函数，将目标卡加入手牌。
function c40737112.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果condition函数，判断是否满足战斗破坏后发动的条件。
function c40737112.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 效果target函数，设置要除外的卡。
function c40737112.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果操作信息，指定将目标卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 效果operation函数，将目标卡除外。
function c40737112.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsAbleToRemove() then
		-- 将目标卡除外。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
