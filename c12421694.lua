--閃刀姫－カイナ
-- 效果：
-- 地属性以外的「闪刀姬」怪兽1只
-- 自己对「闪刀姬-魁奈」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到对方回合结束时不能攻击。
-- ②：只要这张卡在怪兽区域存在，每次自己把「闪刀」魔法卡的效果发动，自己回复100基本分。
function c12421694.initial_effect(c)
	c:SetSPSummonOnce(12421694)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以1只满足 c12421694.matfilter 的怪兽（即地属性以外的「闪刀姬」怪兽）作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,c12421694.matfilter,1,1)
	-- ①：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到对方回合结束时不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12421694,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c12421694.atktg)
	e1:SetOperation(c12421694.atkop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次自己把「闪刀」魔法卡的效果发动，自己回复100基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	-- 将e2在连锁发生时的操作设置为aux.chainreg，用于记录这张卡在连锁发生时存在于怪兽区域（为②效果的后缀判定打下基础）。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次自己把「闪刀」魔法卡的效果发动，自己回复100基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c12421694.reccon)
	e3:SetOperation(c12421694.recop)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：该怪兽作为连接素材时当作「闪刀姬」字段，且属性不是地属性。
function c12421694.matfilter(c)
	return c:IsLinkSetCard(0x1115) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_EARTH)
end
-- 诱发效果的发动条件与取对象：检查特殊召唤成功时能否以对方场上的表侧表示怪兽为对象，并让玩家选择1只表侧表示怪兽作为对象。
function c12421694.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 若效果在发动时进行合法性检查（chk==0），则判断对方场上是否存在1只表侧表示怪兽可作为对象；不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择表侧表示的卡”的卡片选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 在对方主要怪兽区选择1只表侧表示怪兽作为效果对象，并将该对象登记到当前连锁。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：对选择的对象怪兽赋予‘不能攻击’的效果，持续到对方回合结束时。
function c12421694.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中作为效果对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽直到对方回合结束时不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 回复条件的判定：当连锁处理结束时，若该连锁是由自己发动的「闪刀」魔法卡的效果，且这张卡在连锁发生时就在怪兽区域存在，则条件成立。
function c12421694.reccon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x115) and rp==tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 效果处理：执行回复基本分的操作。
function c12421694.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 让自己回复100点基本分，回复原因是效果。
	Duel.Recover(tp,100,REASON_EFFECT)
end
