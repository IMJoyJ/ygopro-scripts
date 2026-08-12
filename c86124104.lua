--終焉の悪魔デミス
-- 效果：
-- 「世界不灭」降临。
-- ①：这张卡的卡名只要在手卡·场上存在当作「终焉之王 迪米斯」使用。
-- ②：这张卡仪式召唤成功的场合发动。选场上1只表侧表示怪兽破坏。
-- ③：这张卡被送去墓地的场合，以自己场上1只仪式怪兽为对象才能发动。只要那只怪兽在自己场上表侧表示存在，对方不能对应自己的仪式怪兽的效果的发动把卡的效果发动。
function c86124104.initial_effect(c)
	-- 将「世界不灭」卡片密码（32828635）添加到该卡的关系代码列表中，以在规则层面表明该卡上记载了其卡名。
	aux.AddCodeList(c,32828635)
	c:EnableReviveLimit()
	-- ①：这张卡的卡名只要在手卡·场上存在当作「终焉之王 迪米斯」使用。
	aux.EnableChangeCode(c,72426662,LOCATION_MZONE+LOCATION_HAND)
	-- ②：这张卡仪式召唤成功的场合发动。选场上1只表侧表示怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86124104,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c86124104.descon)
	e2:SetTarget(c86124104.destg)
	e2:SetOperation(c86124104.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己场上1只仪式怪兽为对象才能发动。只要那只怪兽在自己场上表侧表示存在，对方不能对应自己的仪式怪兽的效果的发动把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86124104,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c86124104.target)
	e3:SetOperation(c86124104.operation)
	c:RegisterEffect(e3)
end
-- 效果②的发动条件：此卡是以仪式召唤的方式特殊召唤成功。
function c86124104.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果②的发动准备：获取场上所有表侧表示的怪兽，并设置破坏的操作信息。
function c86124104.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏刚才获取的场上的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：让玩家选择场上1只表侧表示的怪兽并将其破坏。
function c86124104.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息，提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家在双方场上的表侧表示怪兽中选择1只。
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为所选定的卡片显示被选作对象的特效。
		Duel.HintSelection(g)
		-- 破坏所选的怪兽卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示的仪式怪兽。
function c86124104.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 效果③的发动准备：判断并选择自己场上的1只表侧表示仪式怪兽作为效果的对象。
function c86124104.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86124104.cfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示仪式怪兽。
	if chk==0 then return Duel.IsExistingTarget(c86124104.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示消息，提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上的1只表侧表示仪式怪兽作为效果的对象。
	Duel.SelectTarget(tp,c86124104.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的效果处理：给目标仪式怪兽注册一个在场上时限制对方进行连锁的效果，并添加客户端提示标志。
function c86124104.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果③对象的仪式怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 只要那只怪兽在自己场上表侧表示存在，对方不能对应自己的仪式怪兽的效果的发动把卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c86124104.actop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86124104,2))  --"「终焉之恶魔 迪米斯」效果适用中"
	end
end
-- 限制连锁的处理：当自己发动仪式怪兽的效果时，设置对方不可连锁的效果限制条件。
function c86124104.actop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_RITUAL) and re:IsActiveType(TYPE_MONSTER) and ep==tp then
		-- 设置限制对方玩家进行连锁的连锁限制条件。
		Duel.SetChainLimit(c86124104.chainlm)
	end
end
-- 连锁限制判断：判断进行连锁的玩家和发动效果的玩家是否为同一人（以此使得对方无法连锁）。
function c86124104.chainlm(e,rp,tp)
	return tp==rp
end
