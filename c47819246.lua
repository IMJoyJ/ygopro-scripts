--超量機神剣－マグナスレイヤー
-- 效果：
-- ①：以自己场上1只「超级量子」超量怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：这张卡装备的怪兽攻击力上升那只怪兽的阶级数值×100，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
function c47819246.initial_effect(c)
	-- ①：以自己场上1只「超级量子」超量怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果①的发动条件为：不处于伤害步骤，或虽在伤害步骤但尚未进行伤害计算，即只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c47819246.cost)
	e1:SetTarget(c47819246.target)
	e1:SetOperation(c47819246.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡装备的怪兽攻击力上升那只怪兽的阶级数值×100，
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c47819246.atkval)
	c:RegisterEffect(e2)
	-- ②：向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47819246,0))  --"3次攻击"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c47819246.mtcon)
	e4:SetCost(c47819246.mtcost)
	e4:SetTarget(c47819246.mttg)
	e4:SetOperation(c47819246.mtop)
	c:RegisterEffect(e4)
end
-- ①发动的附加处理：为本卡附加‘连锁处理结束前留在场上’的誓约效果，并注册一个监视本次发动是否被无效的触发效果，用于发动被无效时让本卡留在场上不送墓。
function c47819246.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的编号，用于标记本次发动，供后续判断发动是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- ①：以自己场上1只「超级量子」超量怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c47819246.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监视本次发动是否被无效的持续效果注册到发动者tp，后续若本次连锁被无效则执行tgop处理。
	Duel.RegisterEffect(e2,tp)
end
-- 若收到与本次发动编号相同的连锁被无效事件，且本卡仍与无效连锁相关联，则取消本卡被送去墓地的处理，使其继续留在场上。
function c47819246.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从被无效的连锁事件中取得连锁编号，与之前保存的本次发动编号比较，确认是否为本卡的发动被无效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义可选择对象为：表侧表示、属于‘超级量子’字段的超量怪兽。
function c47819246.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdc) and c:IsType(TYPE_XYZ)
end
-- 效果①发动时选择对象：从自己场上选择1只符合条件的‘超级量子’超量怪兽作为这张卡的装备对象。
function c47819246.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47819246.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件的‘超级量子’超量怪兽，作为效果①能否发动的判定条件。
		and Duel.IsExistingTarget(c47819246.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示‘请选择要装备的卡’的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只符合条件的‘超级量子’超量怪兽，并将该怪兽登记为效果①的对象卡。
	Duel.SelectTarget(tp,c47819246.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本卡效果处理为装备卡效果（CATEGORY_EQUIP），处理时涉及本卡1张。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①处理时：若本卡仍在魔陷区且与发动效果关联，则本卡作为装备卡装备给目标怪兽；若目标怪兽已不合法（离场或不再表侧），则本卡不去墓地，留在场上。
function c47819246.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得效果①发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把本卡作为装备卡装备到目标怪兽上。
		Duel.Equip(tp,c,tc)
		-- ①：这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c47819246.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制条件：本卡只能装备给当前装备怪兽，或者自己场上其他‘超级量子’超量怪兽（防止装备到不符合条件的怪兽）。
function c47819246.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0xdc) and c:IsType(TYPE_XYZ)
end
-- 返回装备怪兽的阶级数值×100，作为攻击力上升量。
function c47819246.atkval(e,c)
	return c:GetRank()*100
end
-- 效果③的发动条件：这张卡处于装备卡状态，当前回合玩家是自己，且当前阶段在战斗阶段（从战斗开始到战斗结束）内。
function c47819246.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断：本卡是装备卡；当前是己方回合；当前阶段处于PHASE_BATTLE_START到PHASE_BATTLE之间（即战斗阶段）。
	return e:GetHandler():IsType(TYPE_EQUIP) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果③的发动COST：把这张装备卡送入墓地，并把它装备的怪兽登记为本连锁的对象，供处理时使用。
function c47819246.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡当前装备的怪兽设置为效果对象，以便效果处理时获取该怪兽。
	Duel.SetTargetCard(c:GetEquipTarget())
	-- 将这张卡作为发动代价送入墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果③发动时确认：装备怪兽在自己场上，且该怪兽没有已存在的EFFECT_EXTRA_ATTACK效果（避免多次赋予额外攻击次数）。
function c47819246.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsControler(tp) and not ec:IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- 效果③处理时：给装备怪兽赋予额外攻击次数+2的效果（原本1次+额外2次=共3次攻击），该效果持续到回合结束。
function c47819246.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果③发动时登记的装备怪兽。
	local ec=Duel.GetFirstTarget()
	if ec:IsLocation(LOCATION_MZONE) and ec:IsFaceup() and ec:IsRelateToEffect(e) then
		-- ③：这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
