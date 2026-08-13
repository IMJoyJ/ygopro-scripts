--CNo.69 紋章死神カオス・オブ・アームズ
-- 效果：
-- 5星怪兽×4
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的卡全部破坏。
-- ②：这张卡有「No.69 纹章神 盾徽」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只超量怪兽为对象才能发动。直到结束阶段，这张卡的攻击力上升那只怪兽的原本攻击力数值，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c11522979.initial_effect(c)
	-- 为这张卡添加超量召唤手续：等级5的怪兽×4（用4只等级5怪兽叠放超量召唤）。
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()
	-- 对应①效果：「对方怪兽的攻击宣言时才能发动。对方场上的卡全部破坏。」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11522979,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c11522979.descon)
	e1:SetTarget(c11522979.destg)
	e1:SetOperation(c11522979.desop)
	c:RegisterEffect(e1)
	-- 对应②效果：「这张卡有「No.69 纹章神 盾徽」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除，以对方场上1只超量怪兽为对象才能发动。直到结束阶段，这张卡的攻击力上升那只怪兽的原本攻击力数值，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11522979,1))  --"获得效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c11522979.condition)
	e2:SetCost(c11522979.cost)
	e2:SetTarget(c11522979.target)
	e2:SetOperation(c11522979.operation)
	c:RegisterEffect(e2)
end
-- 将本卡卡号记录进aux.xyz_number表，值为69，表示此卡作为「No.69」怪兽，用于No.相关规则/效果判定。
aux.xyz_number[11522979]=69
-- ①效果的发动条件函数：检测对方怪兽是否进行了攻击宣言，攻击者是对方怪兽时条件成立。
function c11522979.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击宣言的怪兽的控制者是1-tp（即对方），以此限定为“对方怪兽的攻击宣言”。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果的发动目标/操作信息设定函数：发动时确认对方场上存在卡，并将对方场上全部卡登记为本次将破坏的卡。
function c11522979.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上至少有1张卡存在（不限表示形式），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 取得对方场上的全部卡作为本次破坏对象集合（不取对象的效果）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将本次连锁的操作信息登记为：破坏上述全部卡，数量为其卡数，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理函数：效果结算时取对方场上全部卡，并将其破坏。
function c11522979.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新取得对方场上当前存在的全部卡（以实际处理时场上情况为准）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏这些卡（不取对象，适用效果破坏）。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ②效果的发动条件函数：这张卡的超量素材中存在卡号2407234的「No.69 纹章神 盾徽」时才可发动。
function c11522979.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,2407234)
end
-- ②效果的发动代价函数：取除这张卡的1个超量素材作为COST。
function c11522979.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对象用的过滤器：卡必须是表侧表示且为超量怪兽。
function c11522979.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ②效果的发动目标函数：选择对方场上1只表侧表示超量怪兽为对象，并设定为效果对象。
function c11522979.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11522979.filter(chkc) end
	-- 发动合法性检查：确认对方场上有1只满足条件的表侧超量怪兽可选。
	if chk==0 then return Duel.IsExistingTarget(c11522979.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让选择玩家在对方场上选择1只表侧超量怪兽，并将所选卡登记为效果对象。
	Duel.SelectTarget(tp,c11522979.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理函数：若此卡与对象怪兽都仍表侧且与效果关联，则复制对象怪兽的原本卡名和效果，并获得其原本攻击力数值的上升，直到结束阶段。
function c11522979.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次效果的对象怪兽（超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 对应效果原文「直到结束阶段，这张卡的攻击力上升那只怪兽的原本攻击力数值，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果」中的卡名部分：将这张卡的卡名变为对象怪兽的原本卡名。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 对应效果原文「直到结束阶段，这张卡的攻击力上升那只怪兽的原本攻击力数值」（脚本中若原本攻击力为负则按0处理）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
