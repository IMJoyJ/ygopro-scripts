--幻魔皇ラビエル－天界蹂躙拳
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽解放的场合才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己场上1只「幻魔皇 拉比艾尔」为对象才能发动。这个回合，那只怪兽的攻击力变成2倍，可以向对方怪兽全部各作1次攻击。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡加入手卡。
function c28651380.initial_effect(c)
	-- 将卡号69890967对应的「幻魔皇 拉比艾尔」登记为本卡的关联卡名，用于文本中记述该卡名。
	aux.AddCodeList(c,69890967)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c28651380.sprcon)
	e2:SetTarget(c28651380.sprtg)
	e2:SetOperation(c28651380.sprop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡从手卡丢弃，以自己场上1只「幻魔皇 拉比艾尔」为对象才能发动。这个回合，那只怪兽的攻击力变成2倍，可以向对方怪兽全部各作1次攻击。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28651380,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_HAND)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1,28651380)
	-- 设置①效果只能在伤害步骤的伤害计算前发动（当前不是伤害步骤或伤害计算尚未开始时才能发动），防止在伤害计算后发动。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c28651380.atkcost)
	e3:SetTarget(c28651380.atktg)
	e3:SetOperation(c28651380.atkop)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡加入手卡。
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
-- 特殊召唤条件判定：若用于自身特殊召唤，则检查玩家场上是否有3只怪兽可解放，且解放后主怪兽区仍有空位；c为nil时表示仅查询条件。
function c28651380.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家场上可用于特殊召唤解放的怪兽组（不含手卡）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 在可解放怪兽组中检查是否存在3张满足“解放后主怪兽区仍有空位且可解放”条件的组合，以决定是否满足特殊召唤条件。
	return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp,REASON_SPSUMMON)
end
-- 特殊召唤手续的对象选择：从可解放怪兽组中选择3张满足条件的怪兽作为解放对象，并将选中的组保存到效果标签中供处理时使用。
function c28651380.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家场上可用于特殊召唤解放的怪兽组（不含手卡）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从可解放怪兽组中选出3张满足释放后可腾出主怪兽区空位条件的怪兽。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,3,3,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前选择保存的3张怪兽并解放，作为此次特殊召唤的代价。
function c28651380.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的3只怪兽（解放原因记为特殊召唤）。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果发动代价：检查手卡中的这张卡能否丢弃，若能丢弃则将其送去墓地作为发动代价。
function c28651380.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡丢弃到墓地，作为①效果的发动代价（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断卡片是否为表侧表示的「幻魔皇 拉比艾尔」（卡号69890967），用于①效果取对象。
function c28651380.atkfilter(c)
	return c:IsFaceup() and c:IsCode(69890967)
end
-- ①效果的目标判定/选择：检查并选择自己场上1只表侧表示的「幻魔皇 拉比艾尔」为对象；若传入chkc则验证该卡片是否合法。
function c28651380.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28651380.atkfilter(chkc) end
	-- 发动时判定：自己场上是否存在1只以上表侧表示的「幻魔皇 拉比艾尔」可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c28651380.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「幻魔皇 拉比艾尔」为对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c28651380.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：对对象怪兽赋予攻击力变为2倍，以及可以向对方怪兽全部各作1次攻击的效果，直到回合结束时；若对象仍存在且表侧表示才处理。
function c28651380.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果选择的对象的卡片（唯一目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽的攻击力变成2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 可以向对方怪兽全部各作1次攻击
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
-- 复数攻击效果的适用条件：效果作用卡的当前控制者必须仍是发动者（效果持有玩家），否则不适用攻击全部各1次的效果。
function c28651380.acon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- ②效果发动代价：检查场上是否存在可解放的怪兽，并选择解放自己场上1只怪兽作为发动代价。
function c28651380.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在1只以上可解放的怪兽作为②效果的代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
	-- 向玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只可解放的怪兽作为②效果的解放代价。
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 解放所选怪兽，作为②效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果目标判定：确认墓地中的这张卡可以加入手卡，并设置操作信息为回手牌。
function c28651380.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置连锁处理信息，声明本效果将把墓地中的这张卡加入持有者手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其加入持有者手卡。
function c28651380.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者的手卡，作为②效果的最终处理。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
