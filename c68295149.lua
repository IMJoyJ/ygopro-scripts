--リンクメイル・デーモン
-- 效果：
-- 包含仪式·融合·同调·超量怪兽其中任意种的怪兽2只以上
-- ①：这张卡特殊召唤成功的场合，以自己的场上·墓地1只仪式·融合·同调·超量怪兽为对象才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降作为对象的怪兽的攻击力数值。
-- ②：从额外卡组特殊召唤的自己场上的怪兽不会成为对方怪兽的效果的对象。
-- ③：这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1只仪式·融合·同调·超量怪兽除外。
function c68295149.initial_effect(c)
	-- 为这张卡添加连接召唤手续，需要2只以上的怪兽作为素材，且必须包含满足lcheck过滤条件的怪兽
	aux.AddLinkProcedure(c,nil,2,nil,c68295149.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以自己的场上·墓地1只仪式·融合·同调·超量怪兽为对象才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降作为对象的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68295149,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c68295149.atktg)
	e1:SetOperation(c68295149.atkop)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的自己场上的怪兽不会成为对方怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c68295149.tgtg)
	e2:SetValue(c68295149.tgval)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1只仪式·融合·同调·超量怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c68295149.reptg)
	c:RegisterEffect(e3)
end
-- 连接素材检查：素材组中必须包含至少1只仪式、融合、同调或超量怪兽
function c68295149.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤条件：攻击力大于0、在墓地或场上表侧表示的仪式、融合、同调或超量怪兽
function c68295149.atkfilter(c)
	return c:GetAttack()>0 and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 效果①的发动条件与对象选择判定函数
function c68295149.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c68295149.atkfilter(chkc) end
	-- 检查自己场上或墓地是否存在至少1只满足条件的仪式、融合、同调或超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c68295149.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 并且对方场上存在至少1只表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上或墓地1只满足条件的仪式、融合、同调或超量怪兽作为对象
	Duel.SelectTarget(tp,c68295149.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end
-- 效果①的实际效果处理（下降对方场上所有怪兽的攻击力）
function c68295149.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or (tc:IsLocation(LOCATION_MZONE) and tc:IsFacedown()) then return end
	local atk=tc:GetAttack()
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local sc=g:GetFirst()
	while sc do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降作为对象的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
		sc=g:GetNext()
	end
end
-- 过滤不受对象效果影响的怪兽：必须是从额外卡组特殊召唤的怪兽
function c68295149.tgtg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 判定效果来源：必须是对方玩家发动的怪兽效果
function c68295149.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤可用于代替破坏的卡：自己墓地的仪式、融合、同调或超量怪兽
function c68295149.repfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToRemove()
end
-- 代替破坏效果的判定函数：检查自身是否因战斗或效果被破坏，且墓地有可代替的怪兽
function c68295149.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 并且自己墓地存在至少1只可以除外的仪式、融合、同调或超量怪兽
		and Duel.IsExistingMatchingCard(c68295149.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择用于代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己墓地选择1只仪式、融合、同调或超量怪兽
		local g=Duel.SelectMatchingCard(tp,c68295149.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽表侧表示除外，作为代替破坏的处理
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
