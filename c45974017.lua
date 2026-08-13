--闇魔界の契約書
-- 效果：
-- 「暗魔界的契约书」的①的效果1回合只能使用1次。
-- ①：从以下效果选择1个才能把这个效果发动。
-- ●以自己墓地1只「DD」灵摆怪兽为对象才能发动。那只怪兽在自己的灵摆区域放置。
-- ●从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽在自己的灵摆区域放置。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c45974017.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「暗魔界的契约书」的①的效果1回合只能使用1次。 ①：从以下效果选择1个才能把这个效果发动。 ●以自己墓地1只「DD」灵摆怪兽为对象才能发动。那只怪兽在自己的灵摆区域放置。 ●从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45974017,0))  --"选择1个效果发动"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,45974017)
	e2:SetTarget(c45974017.pctg)
	e2:SetOperation(c45974017.pcop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45974017,3))  --"受到1000伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c45974017.damcon)
	e3:SetTarget(c45974017.damtg)
	e3:SetOperation(c45974017.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数：选择位于墓地或表侧表示的「DD」灵摆怪兽，且该卡未被禁止；用于墓地取对象和额外卡组表侧卡的选择。
function c45974017.pcfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- ①效果发动时的目标处理：先检查灵摆区域是否有空位且至少存在墓地可选对象或额外表侧可选卡；再让玩家选择“从墓地放置”或“从额外卡组放置”，把选择结果存入效果标签；若选墓地则改为取对象效果，若选额外则不取对象。
function c45974017.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45974017.pcfilter(chkc) end
	-- 检查自己墓地是否存在1张满足pcfilter且可成为效果对象的「DD」灵摆怪兽。
	local b1=Duel.IsExistingTarget(c45974017.pcfilter,tp,LOCATION_GRAVE,0,1,nil)
	-- 检查自己额外卡组是否存在1张表侧表示的满足pcfilter的「DD」灵摆怪兽（此方式不取对象）。
	local b2=Duel.IsExistingMatchingCard(c45974017.pcfilter,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then
		-- 若自己的灵摆区域左右两个区域都没有空格，则没有可放置的位置，效果不能发动。
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
		return b1 or b2
	end
	local op=0
	-- 两个选项都可用时，让玩家在“自己墓地放置”和“额外卡组放置”中二选一；返回0表示墓地选项，返回1表示额外卡组选项。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(45974017,1),aux.Stringid(45974017,2))  --"自己墓地1只「DD」灵摆怪兽在灵摆区放置/额外卡组1只「DD」灵摆怪兽在灵摆区放置"
	-- 仅墓地选项可用时，直接选择墓地放置（op为0）。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(45974017,1))  --"自己墓地1只「DD」灵摆怪兽在灵摆区放置"
	-- 仅额外卡组选项可用时，由于SelectOption只有这一个选项会返回0，加1后使op为1（额外卡组放置）。
	else op=Duel.SelectOption(tp,aux.Stringid(45974017,2))+1 end  --"额外卡组1只「DD」灵摆怪兽在灵摆区放置"
	e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 发送“请选择要放置到场上的卡”的选择提示，供后续选择卡时显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从自己墓地选择1张满足pcfilter的「DD」灵摆怪兽作为效果对象，并登记为当前连锁的对象。
		local g=Duel.SelectTarget(tp,c45974017.pcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置操作信息：对象卡将离开墓地，用于连锁处理中涉及墓地变动的效果检测（如王家长眠之谷等）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	else
		e:SetProperty(0)
	end
end
-- ①效果处理：若发动时选择墓地对象，则从墓地取得对象并移动到自己的灵摆区域；若选择额外卡组，则先确认灵摆区域仍有空格，再从额外卡组选1张表侧表示的「DD」灵摆怪兽放置到自己的灵摆区域。
function c45974017.pcop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 取出在当前连锁中登记的墓地对象卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将那张墓地对象怪兽以表侧表示移动到自己的灵摆区域，并适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	else
		-- 处理额外卡组选项时再次确认灵摆区域有空位；若无空位则本次处理不适用。
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		-- 发送“请选择要放置到场上的卡”的选择提示，用于额外卡组选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从自己额外卡组选择1张表侧表示且满足pcfilter的「DD」灵摆怪兽（处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,c45974017.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的额外卡组灵摆怪兽以表侧表示移动到自己的灵摆区域，并适用其效果。
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- ②效果的发动条件：自己的准备阶段到来时满足，因为当前回合玩家等于这张卡的控制者。
function c45974017.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己；是则②效果在该准备阶段满足发动条件。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果发动时的目标与操作信息设定：无追加条件即可发动；将承受伤害的玩家设为自己，伤害数值设为1000，并登记为伤害效果。
function c45974017.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为自己，表示由自己承受伤害。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1000，表示伤害数值。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：对目标玩家造成1000点效果伤害，用于时点相关的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- ②效果处理：从连锁信息中取出伤害对象玩家与伤害数值，实际给予该玩家等量效果伤害。
function c45974017.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和对象参数（分别是伤害对象与伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
