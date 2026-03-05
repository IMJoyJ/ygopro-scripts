--ギミック・パペット－ボム・エッグ
-- 效果：
-- 自己的主要阶段时可以从手卡丢弃1只名字带有「机关傀儡」的怪兽，从以下效果选择1个发动。「机关傀儡-炸蛋头」的效果1回合只能使用1次。
-- ●给与对方基本分800分伤害。
-- ●这张卡的等级直到结束阶段时变成8星。
function c20032555.initial_effect(c)
	-- 创建效果1，用于处理发动条件和效果选择
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20032555,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20032555)
	e1:SetTarget(c20032555.efftg)
	e1:SetOperation(c20032555.effop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测手牌中是否包含名字带有「机关傀儡」的怪兽
function c20032555.cfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果处理函数，用于处理发动时的丢弃操作和选项选择
function c20032555.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c20032555.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张满足条件的卡片作为发动代价
	Duel.DiscardHand(tp,c20032555.cfilter,1,1,REASON_COST+REASON_DISCARD)
	local opt=0
	if e:GetHandler():IsLevel(8) then
		-- 当此卡等级不是8时，选择效果1（造成800伤害）
		opt=Duel.SelectOption(tp,aux.Stringid(20032555,1))  --"给与对方基本分800分伤害"
	else
		-- 当此卡等级是8时，选择效果2（等级变为8）
		opt=Duel.SelectOption(tp,aux.Stringid(20032555,1),aux.Stringid(20032555,2))  --"给与对方基本分800分伤害/这张卡的等级直到结束阶段时变成8星"
	end
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 设置连锁操作信息，指定将对对方造成800伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	else
		e:SetCategory(0)
	end
end
-- 效果处理函数，根据选择的选项执行对应效果
function c20032555.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 对对方造成800点伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	else
		-- 设置等级变化效果，使此卡等级变为8，并在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
	end
end
