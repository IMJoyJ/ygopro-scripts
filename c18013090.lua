--ニトロ・ウォリアー
-- 效果：
-- 「氮素同调士」＋调整以外的怪兽1只以上
-- 只要这张卡在场上表侧表示存在，自己回合自己把魔法卡发动的场合，这张卡的攻击力只在那个回合的伤害计算时只有1次上升1000。此外，这张卡的攻击破坏对方怪兽的伤害计算后才能发动。选择对方场上表侧守备表示存在的1只怪兽变成攻击表示，向那只怪兽只再1次可以继续攻击。
function c18013090.initial_effect(c)
	-- 为氮素战士声明其同调素材中包含「氮素同调士」(96182448)，使相关素材置换/检索等机制能正确识别该素材限制。
	aux.AddMaterialCodeList(c,96182448)
	-- 添加同调召唤手续：调整必须满足tfilter条件（卡名「氮素同调士」或持有相关替代效果的卡），调整以外怪兽任意，合计1只以上。
	aux.AddSynchroProcedure(c,c18013090.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，自己回合自己把魔法卡发动的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18013090.atcon)
	-- 当满足条件（自己回合自己发动魔法卡）的连锁发生时，使用aux.chainreg记录本卡在这次连锁时已在场上存在，用于后续判断本次魔法卡发动时此卡是否在场。
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力只在那个回合的伤害计算时只有1次上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c18013090.atop)
	c:RegisterEffect(e2)
	-- 此外，这张卡的攻击破坏对方怪兽的伤害计算后才能发动。选择对方场上表侧守备表示存在的1只怪兽变成攻击表示，向那只怪兽只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18013090,0))  --"继续攻击"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c18013090.cacon)
	e3:SetTarget(c18013090.catg)
	e3:SetOperation(c18013090.caop)
	c:RegisterEffect(e3)
end
c18013090.material_setcode=0x1017
-- 定义同调素材中“调整”的过滤条件：卡名是「氮素同调士」的怪兽，或持有能让自身视为「氮素同调士」的效果的怪兽（20932152）。
function c18013090.tfilter(c)
	return c:IsCode(96182448) or c:IsHasEffect(20932152)
end
-- 攻击力上升效果的触发条件判定：本连锁的发动者是己方玩家，且当前回合是己方回合，并且发动的是魔法卡的“卡的发动”。
function c18013090.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这次连锁由己方玩家发动，且当前回合是己方回合，确保只在己方回合自己发动魔法卡时才适用。
	return ep==tp and Duel.GetTurnPlayer()==tp
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 在魔法卡连锁处理结束时，若本次连锁发生时的确有本卡在场且本回合尚未使用过该攻击力上升效果，则为本卡注册一个攻击力上升效果，并标记本回合已使用过。
function c18013090.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(FLAG_ID_CHAINING)==0 or c:GetFlagEffect(18013090)~=0 then return end
	-- 这张卡的攻击力只在那个回合的伤害计算时只有1次上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c18013090.atkcon)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	c:RegisterEffect(e2)
	c:RegisterFlagEffect(18013090,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 攻击力上升效果的适用条件：当前处于伤害计算时，且正在进行伤害计算的攻击怪兽是这张卡。
function c18013090.atkcon(e)
	local c=e:GetHandler()
	-- 只在伤害计算阶段且此卡为攻击怪兽时，才适用攻击力+1000。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and c==Duel.GetAttacker()
end
-- 发动“继续攻击”效果的条件：这张卡在战斗中获得战斗对象，且该战斗对象被这次战斗破坏，并且此卡当前满足可以进行再攻击的条件。
function c18013090.cacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsChainAttackable()
end
-- 选择目标的过滤条件：对方场上的表侧守备表示怪兽，且未被战斗破坏。
function c18013090.filter(c)
	return c:IsFaceup() and c:IsDefensePos() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置“继续攻击”效果的发动目标：从对方场上选择1只符合条件的表侧守备表示怪兽，并登记操作信息为改变表示形式。
function c18013090.catg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c18013090.filter(chkc) end
	-- 效果发动时不取对象检查：确认对方场上存在至少1只符合条件的表侧守备表示怪兽，否则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c18013090.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示当前玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从对方场上选择1只符合条件的表侧守备表示怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c18013090.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向系统登记本连锁将执行“改变表示形式”的操作，对象为已选择的目标，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：取对象怪兽若仍与效果相关且表侧表示，则将其变为表侧攻击表示，并使氮素战士可以向那只怪兽再进行一次攻击。
function c18013090.caop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把目标怪兽从表侧守备表示变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		-- 让氮素战士获得对目标怪兽再攻击一次的权限，可继续向那只怪兽攻击。
		Duel.ChainAttack(tc)
	end
end
