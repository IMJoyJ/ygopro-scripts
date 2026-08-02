--アルカナフォースⅩⅡ－THE HANGED MAN
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 特召效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
●正：选择自己场上1只怪兽破坏，给与自己那只怪兽的原本攻击力数值的伤害。
●反：选择对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
	-- 召唤·特殊召唤·反转召唤成功时发动。进行1次掷硬币得到以下效果。●正：选择自己场上1只怪兽破坏，给与自己那只怪兽的原本攻击力数值的伤害。●反：选择对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 检查这张卡是否未公开
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检查卡片是否为「秘仪之力」怪兽且可以表侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查场上是否有主要怪兽区空位以及手卡是否有满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有主要怪兽区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在可以特殊召唤的「秘仪之力」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：包含特殊召唤手卡1只怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 在手卡选择1只满足条件的怪兽进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 洗切手牌
		Duel.ShuffleHand(tp)
		-- 将选中的怪兽表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断掷硬币效果发动条件并设置破坏效果的预期对象
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含掷硬币的效果
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 检查自己场上是否存在怪兽
	if Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)>0
		-- 检查对方场上是否存在怪兽
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)>0 then
		-- 获取双方场上的所有怪兽
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置操作信息：包含破坏场上怪兽的效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- 执行掷硬币并根据结果处理破坏怪兽及伤害逻辑
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local res=-1
	-- 如果受到「光之结界」等可以决定硬币结果的效果影响时
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查自己场上是否存在怪兽
		local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在怪兽
		local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		if b1 and not b2 then
			-- 提示对方选择了正面效果
			Duel.Hint(HINT_OPSELECTED,1-tp,SELECT_HEADS)
			res=1
		end
		if b2 and not b1 then
			-- 提示对方选择了反面效果
			Duel.Hint(HINT_OPSELECTED,1-tp,SELECT_TAILS)
			res=0
		end
		if b1 and b2 then
			-- 让玩家选择硬币的正反面结果
			res=aux.SelectFromOptions(tp,
				{b1,SELECT_HEADS,1},
				{b2,SELECT_TAILS,0})
		end
	else
		-- 执行投掷1次硬币
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择自己场上1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示被选择卡片的对象动画
			Duel.HintSelection(g)
			-- 检查怪兽是否有效
			local flag=aux.covcheck(tc)
			-- 如果成功破坏怪兽且该怪兽在场上的原本攻击力大于0时
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and flag and tc:GetTextAttack()>0 then
				-- 给与自己该怪兽原本攻击力数值的伤害
				Duel.Damage(tp,tc:GetTextAttack(),REASON_EFFECT)
			end
		end
	elseif res==0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择对方场上1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示被选择卡片的对象动画
			Duel.HintSelection(g)
			-- 检查怪兽是否有效
			local flag=aux.covcheck(tc)
			-- 如果成功破坏怪兽且该怪兽在场上的原本攻击力大于0时
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and flag and tc:GetTextAttack()>0 then
				-- 给与对方该怪兽原本攻击力数值的伤害
				Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
			end
		end
	end
end
