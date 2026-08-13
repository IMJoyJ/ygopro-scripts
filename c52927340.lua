--オルターガイスト・クンティエリ
-- 效果：
-- ①：自己场上有「幻变骚灵」卡存在的场合，对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。
-- ②：这张卡特殊召唤成功的场合，以对方场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，那张卡的效果无效化。
function c52927340.initial_effect(c)
	-- ①：自己场上有「幻变骚灵」卡存在的场合，对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52927340,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52927340.condition)
	e1:SetTarget(c52927340.target)
	e1:SetOperation(c52927340.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，那张卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52927340,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c52927340.distg)
	e2:SetOperation(c52927340.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为表侧表示且属于「幻变骚灵」系列（0x103），用于确认自己场上是否存在满足条件的「幻变骚灵」卡。
function c52927340.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103)
end
-- ①效果的发动条件：攻击宣言的怪兽为对方控制，且自己场上有表侧表示的「幻变骚灵」卡存在。
function c52927340.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次攻击宣言的攻击怪兽。
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽是否为对方控制，且自己场上有表侧「幻变骚灵」卡；两者同时满足时条件成立。
	return at:IsControler(1-tp) and Duel.IsExistingMatchingCard(c52927340.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的发动条件与操作信息：在发动时检查自己怪兽区是否有空位、此卡能否特殊召唤，并设置将进行特殊召唤的操作信息。
function c52927340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查自己主要怪兽区有空位，且此卡可以被效果特殊召唤（不检查苏生限制）。两者同时满足才可发动。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁信息：声明此效果将进行1只怪兽的特殊召唤，并指定特殊召唤的卡为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，将其表侧攻击表示特殊召唤到自己的怪兽区；特殊召唤成功时，无效那次攻击。
function c52927340.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡未离开过当前区域（与效果仍关联），并执行特殊召唤；若实际特殊召唤成功（返回>0）则继续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 无效此次攻击宣言（使攻击无效化）。
		Duel.NegateAttack()
	end
end
-- ②效果的发动条件与取对象处理：从对方场上选择1张表侧表示且可以被无效化的卡片作为对象，并设置对应的无效化操作信息。
function c52927340.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象合法性校验：确认连锁中指定的对象位于场上、由对方控制，且能够被无效化。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 发动时检查：在对方场上是否存在至少1张满足“可被无效化”条件的表侧卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择卡片提示，提示文字为“请选择要无效的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 由玩家选择对方场上1张满足条件的卡片，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息：声明此效果将使1张卡的效果无效化，并登记选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果处理：若此卡仍在场上且与效果关联，对象也在场上且与效果关联、不免疫该效果，则将此卡设为对象卡的永续对象，给对象卡附加“效果无效化”状态；若对象是陷阱怪兽，则同时赋予“陷阱怪兽效果无效化”。
function c52927340.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时所选择的对象卡（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，那张卡的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(c52927340.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e2)
		end
	end
end
-- 无效化效果的持续条件：此效果的所有者仍把对象卡视为永续对象（即此卡仍在场且对象关系未解除），从而保证无效化持续。
function c52927340.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
