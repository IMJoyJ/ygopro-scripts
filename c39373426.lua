--SPYRAL MISSION－奪還
-- 效果：
-- 这张卡发动后，第3次的自己结束阶段破坏。
-- ①：1回合1次，自己场上有「秘旋谍」怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽在这个回合不能直接攻击。
-- ②：自己场上的「秘旋谍」怪兽被战斗·效果破坏的场合，可以作为那1只破坏的怪兽的代替而把墓地的这张卡除外。
function c39373426.initial_effect(c)
	-- 这张卡发动后，第3次的自己结束阶段破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(39373426,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(c39373426.target)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己场上有「秘旋谍」怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽在这个回合不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39373426,1))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c39373426.cncon)
	e1:SetCost(c39373426.cncost)
	e1:SetTarget(c39373426.cntg1)
	e1:SetOperation(c39373426.cnop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c39373426.cntg2)
	c:RegisterEffect(e2)
	-- ②：自己场上的「秘旋谍」怪兽被战斗·效果破坏的场合，可以作为那1只破坏的怪兽的代替而把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c39373426.reptg)
	e3:SetValue(c39373426.repval)
	e3:SetOperation(c39373426.repop)
	c:RegisterEffect(e3)
end
-- 发动时的处理：为这张卡注册一个持续效果，在每个自己的结束阶段使这张卡的回合计数器+1，当累计到第3次自己的结束阶段时以规则破坏这张卡。
function c39373426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第3次的自己结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c39373426.descon)
	e1:SetOperation(c39373426.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 自毁计数的条件：仅当当前回合玩家是这张卡的控制者（即自己的结束阶段）时，计数效果才执行。
function c39373426.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，用于限定在‘自己的结束阶段’计数。
	return Duel.GetTurnPlayer()==tp
end
-- 自毁计数的处理：将回合计数器加1；当计数达到3时，以规则原因破坏这张卡。
function c39373426.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 以规则原因（REASON_RULE）破坏这张卡，完成‘第3次的自己结束阶段破坏’。
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 过滤条件：怪兽是表侧表示、属「秘旋谍」系列且由自己控制，用于检测特殊召唤的怪兽中是否存在符合条件的「秘旋谍」怪兽。
function c39373426.cncfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xee) and c:IsControler(tp)
end
-- 诱发条件：这组特殊召唤成功的怪兽中存在至少1只表侧表示且由自己控制的「秘旋谍」怪兽时，满足①效果的发动条件。
function c39373426.cncon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39373426.cncfilter,1,nil,tp)
end
-- 发动①效果的前置费用检查：确认这张卡本回合尚未使用过①效果（无对应flag标记），随后给自己设置该标记，以实现‘1回合1次’的限制。
function c39373426.cncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(39373426)==0 end
	e:GetHandler():RegisterFlagEffect(39373426,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的目标处理（发动时版本）：确认对方场上有可改变控制权的怪兽；提示玩家选择1只作为对象；登记改变控制权的操作信息；并为这张卡注册自毁计数效果。
function c39373426.cntg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 效果发动合法检查：确认对方场上有至少1只当前可以被改变控制权的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家展示“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只可改变控制权的怪兽作为效果对象，并自动与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁的操作信息：效果类别为改变控制权，对象为所选怪兽，数量为1，供后续效果处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	local c=e:GetHandler()
	-- 这张卡发动后，第3次的自己结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c39373426.descon)
	e1:SetOperation(c39373426.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- ①效果的目标处理（场上永续版本）：确认存在可改变控制权的对方怪兽；选择1只作为对象；登记改变控制权的操作信息。
function c39373426.cntg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 效果发动合法检查：确认对方场上有至少1只当前可以被改变控制权的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家展示“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只可改变控制权的怪兽作为效果对象，并自动与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁的操作信息：效果类别为改变控制权，对象为所选怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ①效果的处理：取得对象怪兽，确认其仍与效果相关且成功获得其控制权直到结束阶段；若成功，给该怪兽附加‘本回合不能直接攻击’的效果。
function c39373426.cnop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与效果关联（未被无效或离场重置），并尝试将其控制权直到结束阶段转移给自己；成功转移则进入后续处理。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)>0 then
		-- 这个效果得到控制权的怪兽在这个回合不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 替代破坏的过滤条件：被破坏的怪兽是表侧表示的「秘旋谍」怪兽，位于我方怪兽区、由我方控制，且其破坏原因是战斗或效果破坏，且不是由本次代替破坏自身产生的破坏。
function c39373426.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xee) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动判定与选择：确认墓地这张卡可除外，且本组被破坏怪兽中有符合条件的「秘旋谍」怪兽；询问玩家是否发动；若发动，在候选怪兽中确定1只作为代替保护对象（唯一则直接指定，多只则选择），并返回true。
function c39373426.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c39373426.repfilter,1,nil,tp) end
	-- 弹出选择框，询问玩家是否发动②效果（把墓地的这张卡除外作为代替破坏）。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c39373426.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 当有多个可代替保护的「秘旋谍」怪兽时，提示玩家选择其中1只作为代替破坏的对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 判定某只即将被破坏的怪兽是否正是被选为代替保护的那一只；只有匹配时才会用这张卡代替它破坏。
function c39373426.repval(e,c)
	return c==e:GetLabelObject()
end
-- ②效果发动后的处理：把墓地的这张卡从游戏中除外，完成代替破坏。
function c39373426.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧除外，作为代替破坏的代价/处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
