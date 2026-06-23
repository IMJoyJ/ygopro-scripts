--BK チーフセコンド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时，若自己场上有战士族怪兽或炎属性怪兽存在则能发动。这张卡从手卡特殊召唤，那次攻击无效。那之后，场上1只怪兽直到结束阶段除外。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「燃烧拳击手」怪兽召唤。
function c47921178.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，若自己场上有战士族怪兽或炎属性怪兽存在则能发动。这张卡从手卡特殊召唤，那次攻击无效。那之后，场上1只怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47921178,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,47921178)
	e1:SetCondition(c47921178.spcon)
	e1:SetTarget(c47921178.sptg)
	e1:SetOperation(c47921178.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「燃烧拳击手」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47921178,1))  --"使用「燃烧拳击手 第一助手」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置效果目标为包含「燃烧拳击手」卡组的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1084))
	c:RegisterEffect(e2)
end
-- 攻击宣言时的条件判断函数
function c47921178.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 判断场上是否存在战士族或炎属性怪兽
function c47921178.cfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
end
-- 设置特殊召唤和除外的发动条件检查
function c47921178.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的战士族或炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47921178.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在可除外的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 获取场上所有可除外的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置除外的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果发动后的操作流程
function c47921178.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否与连锁相关并进行特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 无效此次攻击
		and Duel.NegateAttack() then
		-- 提示选择要除外的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择场上一只可除外的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示所选怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 将选定怪兽除外并设置返回效果
			if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				tc:RegisterFlagEffect(47921178,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				-- 注册结束阶段返回场上的持续效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(tc)
				e1:SetCountLimit(1)
				e1:SetCondition(c47921178.retcon)
				e1:SetOperation(c47921178.retop)
				-- 将注册的持续效果加入游戏环境
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 判断是否需要将怪兽返回场上
function c47921178.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(47921178)~=0
end
-- 将指定怪兽返回场上
function c47921178.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
