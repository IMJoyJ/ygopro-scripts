--運命のウラドラ
-- 效果：
-- ①：支付1000基本分，以自己场上1只表侧表示怪兽为对象才能发动。直到对方回合结束时，那只怪兽的攻击力上升1000，以下效果适用。
-- ●那只怪兽战斗破坏对方怪兽时才能发动。自己卡组最下面的卡给双方确认，回到卡组最上面或者最下面。确认的卡是龙族·恐龙族·海龙族·幻龙族怪兽的场合，那个攻击力每有1000，自己从卡组抽1张。那之后，自己回复抽出数量×1000基本分。
function c27753563.initial_effect(c)
	-- ①：支付1000基本分，以自己场上1只表侧表示怪兽为对象才能发动。直到对方回合结束时，那只怪兽的攻击力上升1000，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c27753563.cost)
	e1:SetTarget(c27753563.target)
	e1:SetOperation(c27753563.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：在效果发动前检查并支付1000基本分作为发动代价。
function c27753563.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查阶段，确认当前玩家能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 定义效果目标选择函数：从自己场上选择1只表侧表示怪兽作为对象。
function c27753563.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在目标合法性检查阶段，确认自己场上存在至少1只表侧表示怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽，并登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理函数：若对象怪兽仍与该效果关联且表侧表示，则使其攻击力上升1000，并赋予其战斗破坏时诱发后续效果及战斗破坏标记的辅助效果。
function c27753563.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到对方回合结束时，那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- ●那只怪兽战斗破坏对方怪兽时才能发动。自己卡组最下面的卡给双方确认，回到卡组最上面或者最下面。确认的卡是龙族·恐龙族·海龙族·幻龙族怪兽的场合，那个攻击力每有1000，自己从卡组抽1张。那之后，自己回复抽出数量×1000基本分。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(27753563,0))  --"自己卡组最下面的卡给双方确认"
		e2:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetLabelObject(tc)
		e2:SetCondition(c27753563.cmcon)
		e2:SetTarget(c27753563.cmtg)
		e2:SetOperation(c27753563.cmop)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 将战斗破坏时发动的诱发效果e2注册到当前玩家tp，使该效果在tp场上持续生效，直到对方回合结束。
		Duel.RegisterEffect(e2,tp)
		-- 那只怪兽战斗破坏对方怪兽时才能发动。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EFFECT_DESTROY_REPLACE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCondition(c27753563.regcon)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e3)
	end
end
-- 辅助条件函数：当持有该效果的怪兽作为战斗破坏事件中的怪兽时，给它设置一个战斗破坏标记；返回false表示不实际替代破坏。
function c27753563.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetBattleTarget() and r==REASON_BATTLE then
		c:RegisterFlagEffect(27753563,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
	return false
end
-- 判断当前战斗破坏事件中被破坏的怪兽是否为原对象怪兽，且该对象怪兽带有战斗破坏标记，以决定后续效果能否发动。
function c27753563.cmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(27753563)~=0
end
-- 定义后续诱发效果的目标检查函数：要求自己卡组有卡存在才能发动。
function c27753563.cmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在后续效果发动检查阶段，确认自己卡组至少存在1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 定义后续效果处理函数：将卡组最下方的卡移到最上方并给双方确认，再由玩家选择放回卡组最上方或最下方；若该卡是龙族/恐龙族/海龙族/幻龙族怪兽，则按其攻击力每1000抽1张卡，并回复抽卡数量×1000基本分。
function c27753563.cmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组的全部卡片组，以定位卡组最下方的那张卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()==0 then return end
	local tc=g:GetMinGroup(Card.GetSequence):GetFirst()
	-- 将选中的卡移动到卡组最上方，以便进行确认和后续放回选择。
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	-- 让双方玩家确认自己卡组最上方的1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 由当前玩家选择要将确认的卡放回卡组最上面还是最下面，返回选项编号。
	local opt=Duel.SelectOption(tp,aux.Stringid(27753563,1),aux.Stringid(27753563,2))  --"回到卡组最上面/回到卡组最下面"
	-- 按玩家选项将确认的卡移动到卡组最上方或最下方。
	Duel.MoveSequence(tc,opt)
	if tc:IsRace(RACE_DRAGON) or tc:IsRace(RACE_DINOSAUR) or tc:IsRace(RACE_SEASERPENT) or tc:IsRace(RACE_WYRM) then
		local d=math.floor(tc:GetAttack()/1000)
		-- 以效果原因抽取d张卡（d为确认怪兽攻击力除以1000向下取整），返回实际抽到的张数。
		local dn=Duel.Draw(tp,d,REASON_EFFECT)
		if dn>0 then
			-- 中断当前效果处理，使之后的回复LP处理与抽卡处理分开，以避免错时点。
			Duel.BreakEffect()
			-- 回复当前玩家抽卡数量×1000基本分。
			Duel.Recover(tp,dn*1000,REASON_EFFECT)
		end
	end
end
