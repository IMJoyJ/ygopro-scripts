--ピットナイト・フィル
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在连接怪兽所连接区特殊召唤的场合，以自己场上1只攻击力1500以下的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击，那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，下个回合的准备阶段才能发动。这张卡从墓地特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册连接召唤手续，并登记①效果、被破坏时的记录效果以及②效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：以2只效果怪兽为连接素材进行连接召唤（对应效果原文“效果怪兽2只”）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- ①：这张卡在连接怪兽所连接区特殊召唤的场合，以自己场上1只攻击力1500以下的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击，那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetOperation(s.spreg)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：判定这张卡是否处于连接怪兽所连接的区域（即己方或对方连接怪兽的连接箭头指向的格子）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上所有处于连接状态的卡片组（用于后续检查此卡是否在连接区内）。
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方场上所有处于连接状态的卡片组，并与己方的合并，以覆盖全场连接状态。
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 目标筛选函数：选择表侧表示且攻击力1500以下的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500)
end
-- ①效果的目标选择：选择自己场上1只攻击力1500以下且表侧表示的怪兽作为效果对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动合法性检查：必须处于战斗阶段，且自己场上存在符合条件的表侧表示怪兽。
	if chk==0 then return aux.bpcon() and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件（表侧表示且攻击力1500以下）的怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：给对象怪兽赋予‘同1次战斗阶段可作2次攻击’和‘给予对方战斗伤害翻倍’的效果（持续到这个回合结束）。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 那只怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetCondition(s.damcon)
		-- 设置战斗伤害变更效果的具体数值：将对象怪兽给予对方的战斗伤害变为2倍（DOUBLE_DAMAGE）。
		e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		tc:RegisterEffect(e2)
	end
end
-- 伤害翻倍效果的条件：仅当该怪兽与对方怪兽进行战斗（存在战斗对象）时才适用。
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- ②效果的前置记录：这张卡被战斗或效果破坏并送去墓地时，登记下个回合准备阶段的特殊召唤标记。
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 将记录标签设置为‘当前回合数+1’，即下个回合，用于指定②效果可发动的准备阶段。
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- ②效果的发动条件：当前回合数等于e2记录的回合数（下个回合），且这张卡带有被破坏的flag标记。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断：e2记录的回合数是否等于当前回合数，且此卡存在被破坏标记（flag效果数量>0）。
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的发动合法性检查：主要怪兽区有空位，且这张卡可以从墓地特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将进行特殊召唤（对象为这张卡，1只）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(id)
end
-- ②效果处理：若这张卡仍与效果关联，则将其从墓地特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡从墓地特殊召唤到tp的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
