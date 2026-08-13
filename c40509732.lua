--鬼動武者
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡和对方怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动，只在那次战斗阶段内那只对方怪兽的效果无效化。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 定义鬼动武者的效果注册函数：先赋予同调召唤限制/复活限制，并注册同调召唤手续；随后注册①的“禁止对方发动效果”和“无效对方怪兽效果”两部分，以及②的离场时从墓地特召机械族怪兽的效果。
function c40509732.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续：需要调整＋调整以外的怪兽1只以上（这里的调整和非调整均未限定具体种族/属性/卡名）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(),1)
	-- 对应①中“这张卡和对方怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动”的部分，此处的actcon用于判断这张卡正在与对方怪兽战斗。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c40509732.actcon)
	c:RegisterEffect(e1)
	-- 对应①中“只在那次战斗阶段内那只对方怪兽的效果无效化”的标记部分，通过战斗对象选定事件记录对方那只战斗怪兽，以便后续无效其效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.discon1)
	e2:SetOperation(s.disop1)
	c:RegisterEffect(e2)
	-- 对应①中“只在那次战斗阶段内那只对方怪兽的效果无效化”的无效部分，对带有标记的对方怪兽无效化其效果。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(s.distg)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e7)
	-- 对应②“表侧表示的这张卡因对方的效果从场上离开的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。”，代码实现离场触发、取对象及特殊召唤的处理。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40509732,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c40509732.spcon)
	e4:SetTarget(c40509732.sptg)
	e4:SetOperation(c40509732.spop)
	c:RegisterEffect(e4)
end
-- ①的发动/适用条件：判断这张卡目前正与对方怪兽进行战斗（这张卡是攻击者且存在战斗对象，或这张卡是攻击对象）。
function c40509732.actcon(e)
	local c=e:GetHandler()
	-- 返回是否满足战斗条件：当这张卡作为攻击者且拥有战斗对象，或这张卡作为被攻击对象时为真。
	return (Duel.GetAttacker()==c and c:GetBattleTarget()) or Duel.GetAttackTarget()==c
end
-- 标记事件的额外触发条件：当这张卡参与战斗（作为攻击者或被攻击对象）且存在战斗对象时，本次事件处理才会执行。
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡当前处于战斗状态并存在战斗对象，用于确定需要无效化的对方怪兽。
	return (c==Duel.GetAttacker() or c==Duel.GetAttackTarget()) and c:GetBattleTarget()
end
-- 将这名与这张卡交战的对方怪兽登记一个以本卡id为标志的flag，持续到战斗阶段结束或该卡离场等标准重置时；随后立即刷新无效状态，使无效效果马上适用。
function s.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 手动刷新场上受这张卡影响的卡的无效状态，使刚被标记的对方怪兽立刻被e6/e7的无效效果作用。
	Duel.AdjustInstantly(c)
end
-- 无效化效果的选取目标：只选择带有本卡id标志的卡，也就是那次战斗中与这张卡交战的对方怪兽。
function s.distg(e,c)
	return c:GetFlagEffect(id)~=0
end
-- ②的发动条件：这张卡因对方控制的效果从场上离开，且离场前是由自己控制并表侧表示。
function c40509732.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②墓地对象的过滤函数：选择机械族怪兽，且该怪兽能够被当前效果通常特殊召唤。
function c40509732.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②发动时的目标检查和选择：需要自己场上有可用的怪兽区域，且墓地存在至少1只符合条件的机械族怪兽；选中后将其设为对象并登记特殊召唤操作信息。
function c40509732.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c40509732.filter(chkc,e,tp) end
	-- 非取对象部分检查：自己场上必须存在可用的怪兽区域空格，才能发动②。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在至少1只满足过滤条件、可作为效果对象的机械族怪兽。
		and Duel.IsExistingTarget(c40509732.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的机械族怪兽，并将其作为这个效果的对象。
	local g=Duel.SelectTarget(tp,c40509732.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：这个效果将进行1只怪兽的特殊召唤，对象为已选择的墓地机械族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②的效果处理：取得发动时选择的对象，若该卡仍与本效果关联，则将其以表侧表示特殊召唤到自己场上。
function c40509732.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡（墓地那只机械族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上（sumtype为0，同时按规则检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
