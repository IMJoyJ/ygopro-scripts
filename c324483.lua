--極炎の剣士
-- 效果：
-- 「炎之剑士」＋「斗气炎斩龙」
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那只怪兽破坏，给与对方500伤害。
-- ②：这张卡进行战斗的伤害步骤开始时才能发动。这张卡的攻击力直到回合结束时变成2倍。这个回合的结束阶段这张卡破坏。
local s,id,o=GetID()
-- 初始化效果：为「极炎之剑士」添加苏生限制与融合召唤手续，并注册①的破坏/伤害效果（分通常起动版和装备时快速版）以及②的战斗时攻击力翻倍·结束阶段自毁效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：以「炎之剑士」(45231177)和「斗气炎斩龙」(36319131)为融合素材，允许使用融合素材代用品。
	aux.AddFusionProcCode2(c,45231177,36319131,true,true)
	-- ①：以对方场上1只怪兽为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那只怪兽破坏，给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏对方怪兽"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.descon2)
	c:RegisterEffect(e2)
	-- ②：这张卡进行战斗的伤害步骤开始时才能发动。这张卡的攻击力直到回合结束时变成2倍。这个回合的结束阶段这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击力翻倍"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- ①效果（通常起动版）的发动条件：这张卡没有装备卡装备时才能发动。
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()==0
end
-- ①效果（快速效果版）的发动条件：这张卡有装备卡装备时，可以在对方回合等自由时点发动。
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()>0
end
-- ①效果的发动处理：选择对方场上1只怪兽为对象，并设定破坏和伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动合法性检查：确认对方场上存在至少1只可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，让玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定操作信息：将所选对象卡作为本次破坏效果的目标，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设定操作信息：本次效果会给对方造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ①效果处理：取得对象怪兽，若其仍与效果关联且是怪兽，则将其破坏；破坏成功后再给予对方500伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然与效果关联、是怪兽，并以效果将其破坏；若破坏成功则继续。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 以效果给予对方玩家500点伤害。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡正在进行战斗（伤害步骤开始时）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle()
end
-- ②效果处理：将这张卡的攻击力变成当前攻击力的2倍（直到回合结束），并设置结束阶段将其破坏的辅助效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c:GetAttack()*2)
		c:RegisterEffect(e1)
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local sg=Group.FromCards(c)
		sg:KeepAlive()
		-- 这个回合的结束阶段这张卡破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(sg)
		e2:SetCondition(s.descon3)
		e2:SetOperation(s.desop3)
		-- 将结束阶段破坏这张卡的辅助效果注册到场上，以便在该阶段触发。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤函数：判断某张卡是否带有本次发动②效果时记录的标记（用于找到发动过效果的那张卡）。
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段自毁效果的触发条件：若记录的那张卡仍存在且标记正确，则允许执行破坏；否则取消并清理辅助效果。
function s.descon3(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段自毁效果处理：取出记录的那张卡，将其作为破坏对象。
function s.desop3(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(s.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 将这张卡破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
