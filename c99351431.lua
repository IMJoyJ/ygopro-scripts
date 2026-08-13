--盗賊の極意
-- 效果：
-- 只能在主要阶段一发动。选择场上的1只表侧表示存在的怪兽。在这个回合，选择的怪兽每次给与对方玩家战斗伤害，对方随机丢弃1张手卡。
function c99351431.initial_effect(c)
	-- 只能在主要阶段一发动。选择场上的1只表侧表示存在的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99351431.target)
	e1:SetOperation(c99351431.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的合法性判定与取对象：检查当前为主要阶段1且场上存在表侧表示怪兽；若为对象回查则校验对象是否在场上表侧表示。
function c99351431.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查当前是否为主要阶段1（发动时必须处于主要阶段一）。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1
		-- 检查场上是否存在至少1只表侧表示怪兽，作为可选择为对象的合法目标。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送系统选择提示，提示当前玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从场上选择1只表侧表示怪兽，将其设为该效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时：确认对象仍合法后，给该怪兽附加标记，并为其注册本回合内战斗伤害时随机丢对方手牌的诱发效果。
function c99351431.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and tc:GetFlagEffect(99351431)==0 then
		tc:RegisterFlagEffect(99351431,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 在这个回合，选择的怪兽每次给与对方玩家战斗伤害，对方随机丢弃1张手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(99351431,0))  --"丢弃手牌"
		e1:SetCategory(CATEGORY_HANDES_OPPO)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_DAMAGE)
		e1:SetLabelObject(tc)
		e1:SetCondition(c99351431.hdcon)
		e1:SetTarget(c99351431.hdtg)
		e1:SetOperation(c99351431.hdop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将新建的诱发效果注册到全局环境，使后续满足条件时自动触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定触发条件：受到战斗伤害的是对方玩家，且造成伤害的怪兽正是被选择并带有标记的怪兽。
function c99351431.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:GetFirst()==e:GetLabelObject() and eg:GetFirst():GetFlagEffect(99351431)~=0
end
-- 诱发效果发动时无追加对象，直接返回可发动，并登记操作信息为对方随机丢弃手牌。
function c99351431.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：该效果会将对方1张手牌随机丢弃，用于连锁和时点判定。
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理：从对方手牌中随机选择1张送入墓地，完成随机丢弃。
function c99351431.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌区域的全部卡，并从中随机选取1张。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	-- 将随机选中的1张手牌送去墓地，丢弃原因记为效果和代价。
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_COST)
end
