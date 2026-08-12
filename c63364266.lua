--ゴヨウ・チェイサー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡的攻击力上升这张卡以外的场上的战士族·地属性的同调怪兽数量×300。
-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽的攻击力变成一半在自己场上特殊召唤。
function c63364266.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡以外的场上的战士族·地属性的同调怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c63364266.val)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽的攻击力变成一半在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63364266,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置效果发动条件为自身战斗破坏对方怪兽并送去墓地
	e2:SetCondition(aux.bdogcon)
	e2:SetTarget(c63364266.sptg)
	e2:SetOperation(c63364266.spop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的战士族·地属性同调怪兽的条件函数
function c63364266.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 计算攻击力上升值的回调函数
function c63364266.val(e,c)
	-- 获取双方场上除自身以外满足条件的怪兽数量并乘以300作为攻击力上升值
	return Duel.GetMatchingGroupCount(c63364266.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*300
end
-- 特殊召唤效果的发动准备与合法性检测函数
function c63364266.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 在发动效果前，检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将战斗破坏的对方怪兽注册为效果处理的对象
	Duel.SetTargetCard(bc)
	-- 向系统宣告该效果包含特殊召唤该怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 特殊召唤效果的具体执行函数
function c63364266.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时成为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 尝试将目标怪兽以表侧表示特殊召唤到自己场上（分解步骤）
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 那只怪兽的攻击力变成一半
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
