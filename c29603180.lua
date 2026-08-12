--ディザスター・デーモン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。这个效果把表侧表示的恶魔族怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那些怪兽的原本攻击力合计数值的一半。
function c29603180.initial_effect(c)
	-- ①：以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。这个效果把表侧表示的恶魔族怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那些怪兽的原本攻击力合计数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29603180,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29603180)
	e1:SetTarget(c29603180.destg)
	e1:SetOperation(c29603180.desop)
	c:RegisterEffect(e1)
end
-- 选择破坏对象，从自己和对方场上各选择1张卡作为破坏对象。
function c29603180.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择破坏对象的条件，即自己和对方场上至少各有一张卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为破坏对象。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息，确定要破坏的卡为2张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 判断被破坏的卡是否为表侧表示的恶魔族怪兽。
function c29603180.atkfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_FIEND)~=0
end
-- 处理效果的破坏和攻击力上升部分。
function c29603180.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次连锁中被选择作为破坏对象的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 确认破坏对象存在且成功破坏，同时自身怪兽处于正面表示状态。
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取实际被破坏的卡组。
		local og=Duel.GetOperatedGroup()
		local ag=og:Filter(c29603180.atkfilter,nil)
		local atk=ag:GetSum(Card.GetTextAttack)/2
		-- 将攻击力提升效果应用到自身怪兽上，提升值为被破坏的恶魔族怪兽原本攻击力总和的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
