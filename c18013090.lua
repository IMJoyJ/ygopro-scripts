--ニトロ・ウォリアー
-- 效果：
-- 「氮素同调士」＋调整以外的怪兽1只以上
-- 只要这张卡在场上表侧表示存在，自己回合自己把魔法卡发动的场合，这张卡的攻击力只在那个回合的伤害计算时只有1次上升1000。此外，这张卡的攻击破坏对方怪兽的伤害计算后才能发动。选择对方场上表侧守备表示存在的1只怪兽变成攻击表示，向那只怪兽只再1次可以继续攻击。
function c18013090.initial_effect(c)
	-- 为怪兽添加允许使用的素材卡牌代码，这里添加了氮素同调士的卡号作为可使用素材
	aux.AddMaterialCodeList(c,96182448)
	-- 设置该怪兽的同调召唤条件，需要1只满足tfilter条件的调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,c18013090.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，自己回合自己把魔法卡发动的场合，这张卡的攻击力只在那个回合的伤害计算时只有1次上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18013090.atcon)
	-- 记录连锁发生时这张卡在场上存在
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- 这张卡的攻击破坏对方怪兽的伤害计算后才能发动。选择对方场上表侧守备表示存在的1只怪兽变成攻击表示，向那只怪兽只再1次可以继续攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c18013090.atop)
	c:RegisterEffect(e2)
	-- 选择对方场上表侧守备表示存在的1只怪兽变成攻击表示，向那只怪兽只再1次可以继续攻击
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
-- 过滤满足条件的调整或拥有特定效果的怪兽作为同调召唤的调整
function c18013090.tfilter(c)
	return c:IsCode(96182448) or c:IsHasEffect(20932152)
end
-- 判断是否为己方回合且己方发动魔法卡
function c18013090.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为己方回合
	return ep==tp and Duel.GetTurnPlayer()==tp
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 当魔法卡发动并处理完毕后，若满足条件则给自身增加1000攻击力
function c18013090.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(FLAG_ID_CHAINING)==0 or c:GetFlagEffect(18013090)~=0 then return end
	-- 给自身增加1000攻击力
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
-- 判断当前是否处于伤害计算阶段且该卡为攻击怪兽
function c18013090.atkcon(e)
	local c=e:GetHandler()
	-- 判断当前是否处于伤害计算阶段且该卡为攻击怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and c==Duel.GetAttacker()
end
-- 判断攻击破坏的对方怪兽是否被破坏且该卡可以进行连锁攻击
function c18013090.cacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsChainAttackable()
end
-- 过滤对方场上表侧守备表示且未被破坏的怪兽
function c18013090.filter(c)
	return c:IsFaceup() and c:IsDefensePos() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置选择目标的条件并提示选择
function c18013090.catg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c18013090.filter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c18013090.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上表侧守备表示存在的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c18013090.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示要改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 将目标怪兽变为攻击表示并使其可以再进行1次攻击
function c18013090.caop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变为攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		-- 使目标怪兽可以再进行1次攻击
		Duel.ChainAttack(tc)
	end
end
