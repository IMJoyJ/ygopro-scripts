--グリッド・ロッド
-- 效果：
-- 自己场上的电子界族怪兽才能装备。
-- ①：装备怪兽的攻击力上升300，不受对方的效果影响，1回合只有1次不会被战斗破坏。
-- ②：场上的表侧表示的这张卡被破坏送去墓地的场合才能发动。自己场上的全部电子界族怪兽直到回合结束时不会被战斗·效果破坏。
function c30552375.initial_effect(c)
	-- 自己场上的电子界族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c30552375.target)
	e1:SetOperation(c30552375.operation)
	c:RegisterEffect(e1)
	-- 自己场上的电子界族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c30552375.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 不受对方的效果影响
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c30552375.efilter)
	c:RegisterEffect(e4)
	-- 1回合只有1次不会被战斗破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetValue(c30552375.valcon)
	e5:SetCountLimit(1)
	c:RegisterEffect(e5)
	-- ②：场上的表侧表示的这张卡被破坏送去墓地的场合才能发动。自己场上的全部电子界族怪兽直到回合结束时不会被战斗·效果破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(30552375,0))  --"全部电子界族怪兽不会被破坏"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c30552375.indcon)
	e6:SetTarget(c30552375.indtg)
	e6:SetOperation(c30552375.indop)
	c:RegisterEffect(e6)
end
-- 过滤函数：判断怪兽是否为表侧表示且种族为电子界，用于选择可以装备的对象以及后续保护对象。
function c30552375.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 装备魔法发动时的目标选择处理：检查存在可装备的表侧电子界族怪兽，提示玩家选择1只作为装备对象，并设置本次操作信息为装备。
function c30552375.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30552375.filter(chkc) end
	-- 效果发动合法性检查：确认自己场上有至少1只表侧电子界族怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c30552375.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择提示，缓存“请选择要装备的卡”的文本，用于接下来的卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1张表侧电子界族怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c30552375.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为“装备”，对象为这张装备卡，数量1，使相关卡能触发对应的连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动后的效果处理：取得选择的装备对象，若此卡和对象仍与效果关联且对象表侧表示，则将此卡装备给对象。
function c30552375.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备魔法卡装备到对象怪兽身上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制判定：只有控制者为自己场上、且种族为电子界的怪兽才能装备这张卡。
function c30552375.eqlimit(e,c)
	return c:IsRace(RACE_CYBERSE) and c:GetControler()==e:GetHandler():GetControler()
end
-- 免疫效果判定：若某效果的持有者不是装备怪兽的控制者（即对方的效果），则装备怪兽不受该效果影响。
function c30552375.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 破坏抗性条件判定：仅当破坏原因为战斗破坏时，才计入每回合1次的“不会被战斗破坏”次数。
function c30552375.valcon(e,re,r,rp)
	return r==REASON_BATTLE
end
-- ②效果的发动条件：这张卡在场上表侧表示存在时被破坏并送去墓地的场合才能发动。
function c30552375.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY)
end
-- ②效果发动时的合法性检查：确认自己场上有至少1只表侧电子界族怪兽可作为保护对象。
function c30552375.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动判定：若自己场上不存在表侧电子界族怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30552375.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果处理：获取自己场上全部表侧电子界族怪兽，给每只怪兽赋予直到回合结束时的“不会被战斗破坏”和“不会被效果破坏”效果，并设置客户端提示文本。
function c30552375.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有表侧表示且种族为电子界的怪兽集合。
	local g=Duel.GetMatchingGroup(c30552375.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部电子界族怪兽直到回合结束时不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(30552375,1))  --"「网格杖」效果适用中"
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
