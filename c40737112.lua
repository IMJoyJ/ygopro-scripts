--混沌の黒魔術師
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的回合的结束阶段，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡战斗破坏对方怪兽的伤害计算后发动。那只对方怪兽除外。
-- ③：表侧表示的这张卡从场上离开的场合除外。
function c40737112.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的回合的结束阶段，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
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
	-- 为这张卡添加③效果：表侧表示的这张卡从场上离开的场合除外的离场重定向（离场时改为除外）。
	aux.AddBanishRedirect(c)
	if not c40737112.global_check then
		c40737112.global_check=true
		-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的回合的结束阶段，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。②：这张卡战斗破坏对方怪兽的伤害计算后发动。那只对方怪兽除外。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(40737112)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 为全局监听效果ge1设置操作函数aux.sumreg：在通常召唤成功时给对应怪兽打上“本回合召唤”标记，用于①效果发动条件判定。
		ge1:SetOperation(aux.sumreg)
		-- 将ge1注册为全场持续效果，监听所有玩家的通常召唤成功，配合①的召唤回合限制。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(40737112)
		-- 将ge2注册为全场持续效果，监听所有玩家的特殊召唤成功，配合①的召唤回合限制。
		Duel.RegisterEffect(ge2,0)
	end
end
-- thcost：①效果的发动代价/条件检查——若此卡没有40737112号标记（本回合未被召唤·特殊召唤过）则不能发动，发动时消耗该标记，实现“召唤·特殊召唤的回合的结束阶段”的限制。
function c40737112.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(40737112)~=0 end
	e:GetHandler():ResetFlagEffect(40737112)
end
-- thfilter：过滤条件，选择的对象必须是魔法卡且能够加入手卡。
function c40737112.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- thtg：目标选择函数，从自己墓地选择1张魔法卡作为效果对象，并设置回手牌的操作信息。
function c40737112.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40737112.thfilter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少1张可加入手卡的魔法卡，存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(c40737112.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，让玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1张魔法卡作为对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,c40737112.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将对象卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- thop：效果处理，取得对象卡，若仍与效果关联，则将那张魔法卡加入持有者手卡。
function c40737112.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象的第1张卡（此处即唯一对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象魔法卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- rmcon：②效果的触发条件——这张卡与对方怪兽进行过战斗，且对方怪兽被战斗破坏（伤害计算后），将战斗对象存入LabelObject。
function c40737112.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- rmtg：②效果的目标设定，直接设置操作信息为除外战斗对象，无额外选择。
function c40737112.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果处理时将战斗对象除外（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- rmop：效果处理，若战斗对象仍与战斗相关且可除外，则将其除外。
function c40737112.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsAbleToRemove() then
		-- 以效果原因将战斗对象怪兽表侧表示除外。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
