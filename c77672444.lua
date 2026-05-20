--モーターバイオレンス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合或者自己场上有这张卡以外的机械族怪兽召唤·特殊召唤的场合才能发动。那些召唤·特殊召唤的怪兽直到对方回合结束时攻击力上升那原本守备力一半数值，不能把表示形式变更。
-- ②：上级召唤的这张卡被送去墓地的场合才能发动。在自己场上把2只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
function c77672444.initial_effect(c)
	-- 注册该卡记有卡名「马达齿轮」
	aux.AddCodeList(c,82556059)
	-- ①：这张卡召唤·特殊召唤成功的场合或者自己场上有这张卡以外的机械族怪兽召唤·特殊召唤的场合才能发动。那些召唤·特殊召唤的怪兽直到对方回合结束时攻击力上升那原本守备力一半数值，不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,77672444)
	e1:SetTarget(c77672444.atktg)
	e1:SetOperation(c77672444.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：上级召唤的这张卡被送去墓地的场合才能发动。在自己场上把2只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,77672445)
	e3:SetCondition(c77672444.spcon)
	e3:SetTarget(c77672444.sptg)
	e3:SetOperation(c77672444.spop)
	c:RegisterEffect(e3)
end
-- 过滤出自己场上表侧表示、原本守备力大于0的机械族怪兽
function c77672444.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_MACHINE) and c:GetBaseDefense()>0
end
-- ①号效果的发动准备（检查是否有符合条件的召唤·特殊召唤的怪兽，并将其设为效果处理的对象）
function c77672444.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c77672444.filter,1,nil,tp) end
	local g=eg:Filter(c77672444.filter,nil,tp)
	-- 将符合条件的召唤·特殊召唤的怪兽设为当前连锁的处理对象
	Duel.SetTargetCard(g)
end
-- ①号效果的处理（使作为对象的怪兽攻击力上升原本守备力的一半，且不能变更表示形式）
function c77672444.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍存在于场上且表侧表示的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 那些召唤·特殊召唤的怪兽直到对方回合结束时攻击力上升那原本守备力一半数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(math.floor(tc:GetBaseDefense()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- 不能把表示形式变更
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 检查此卡是否在怪兽区域上级召唤成功后被送去墓地
function c77672444.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- ②号效果的发动准备（检查是否能特殊召唤2只衍生物，并设置特殊召唤和衍生物分类的操作信息）
function c77672444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能特殊召唤「马达衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,77672445,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) end
	-- 设置在当前连锁中产生2只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置在当前连锁中特殊召唤2只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②号效果的处理（在自己场上将2只「马达衍生物」以攻击表示特殊召唤）
function c77672444.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的怪兽区域空位不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 若玩家此时不能特殊召唤「马达衍生物」，则不处理效果
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,77672445,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	for i=1,2 do
		-- 创建「马达衍生物」卡片数据
		local token=Duel.CreateToken(tp,77672445)
		-- 逐步将「马达衍生物」以表侧攻击表示特殊召唤
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 完成所有怪兽的特殊召唤
	Duel.SpecialSummonComplete()
end
