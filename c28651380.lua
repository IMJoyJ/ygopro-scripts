--幻魔皇ラビエル－天界蹂躙拳
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽解放的场合才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己场上1只「幻魔皇 拉比艾尔」为对象才能发动。这个回合，那只怪兽的攻击力变成2倍，可以向对方怪兽全部各作1次攻击。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡加入手卡。
function c28651380.initial_effect(c)
	-- 记录该卡牌效果中涉及的另一张卡牌编号为69890967
	aux.AddCodeList(c,69890967)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只怪兽解放的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c28651380.sprcon)
	e2:SetTarget(c28651380.sprtg)
	e2:SetOperation(c28651380.sprop)
	c:RegisterEffect(e2)
	-- 把这张卡从手卡丢弃，以自己场上1只「幻魔皇 拉比艾尔」为对象才能发动。这个回合，那只怪兽的攻击力变成2倍，可以向对方怪兽全部各作1次攻击。这个效果在对方回合也能发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28651380,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_HAND)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1,28651380)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e3:SetCondition(aux.dscon)
	e3:SetCost(c28651380.atkcost)
	e3:SetTarget(c28651380.atktg)
	e3:SetOperation(c28651380.atkop)
	c:RegisterEffect(e3)
	-- 这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28651380,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,28651381)
	e4:SetCost(c28651380.thcost)
	e4:SetTarget(c28651380.thtg)
	e4:SetOperation(c28651380.thop)
	c:RegisterEffect(e4)
end
-- 检查玩家场上是否存在至少3张满足条件并且不等于自身且可解放的卡
function c28651380.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的怪兽组（非上级召唤用）
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查是否能选出3张满足条件的怪兽进行解放
	return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp,REASON_SPSUMMON)
end
-- 选择满足条件的3张怪兽进行解放
function c28651380.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组（非上级召唤用）
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放的怪兽组中选择3张满足条件的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,3,3,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c28651380.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽组进行解放
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 支付效果的费用：将自身从手牌丢弃至墓地
function c28651380.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手牌丢弃至墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义效果对象的过滤条件：必须是表侧表示且编号为69890967的怪兽
function c28651380.atkfilter(c)
	return c:IsFaceup() and c:IsCode(69890967)
end
-- 选择效果对象：选择自己场上满足条件的怪兽
function c28651380.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28651380.atkfilter(chkc) end
	-- 判断是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c28651380.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c28651380.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果：使目标怪兽攻击力翻倍并可向对方所有怪兽各作一次攻击
function c28651380.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力变为原本的2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽在本回合可以向对方所有怪兽各作一次攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		e2:SetCondition(c28651380.acon)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2)
	end
end
-- 判断效果是否在发动者回合中生效
function c28651380.acon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 支付效果的费用：选择并解放场上1只怪兽
function c28651380.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以解放场上1只怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从场上选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 将指定的怪兽进行解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理时的操作信息：将此卡加入手牌
function c28651380.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置效果处理时的操作信息：将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 执行效果：将此卡加入手牌
function c28651380.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
