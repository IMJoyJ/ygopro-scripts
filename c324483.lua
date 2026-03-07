--極炎の剣士
-- 效果：
-- 「炎之剑士」＋「斗气炎斩龙」
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那只怪兽破坏，给与对方500伤害。
-- ②：这张卡进行战斗的伤害步骤开始时才能发动。这张卡的攻击力直到回合结束时变成2倍。这个回合的结束阶段这张卡破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤条件并注册三个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为45231177和36319131的两只怪兽作为融合素材
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
-- 效果①的发动条件：此卡没有装备卡
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()==0
end
-- 效果②的发动条件：此卡有装备卡
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()>0
end
-- 效果①的发动时选择目标，选择对方场上的1只怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断是否满足效果①的发动条件，即对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要给予对方500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果①的处理函数，破坏目标怪兽并给予对方500伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上且为怪兽类型，并进行破坏
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给予对方500伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 效果②的发动条件：此卡参与了战斗
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle()
end
-- 效果②的处理函数，使此卡攻击力翻倍并在回合结束时破坏
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡攻击力设为原来的2倍
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
		-- 注册一个回合结束时自动破坏此卡的效果
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
		-- 将效果②的破坏效果注册到游戏环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤函数，判断怪兽是否具有指定的flag
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 判断是否需要触发效果②的破坏处理
function s.descon3(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 处理效果②的破坏操作，销毁符合条件的怪兽
function s.desop3(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(s.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 将符合条件的怪兽破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
