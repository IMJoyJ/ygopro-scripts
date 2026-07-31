--アルカナフォースⅩⅡ－THE HANGED MAN
local s,id,o=GetID()
-- 初始化卡片效果：注册①连锁特召手牌「秘仪之力」、②召·特召·反转召成功掷硬币破坏怪兽并扣血效果
function s.initial_effect(c)
	-- ①：连锁中卡的效果发动时，展示手卡的这张卡才能发动。从手卡把1只「秘仪之力」怪兽表侧守备表示特殊召唤。
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
	-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次掷硬币，出现的正反面效果适用。正：选自己场上1只怪兽破坏，给与自己那个原本攻击力数值的伤害。反：选对方场上1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
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
-- ①效果发动Cost：手卡中的此卡未公开
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 特召过滤条件：「秘仪之力」怪兽且可以表侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果发动准备：检查怪兽区域空位与手卡可特召的「秘仪之力」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：手卡是否存在可表侧守备表示特召的「秘仪之力」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：从手卡选1只「秘仪之力」怪兽表侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只符合条件的「秘仪之力」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 洗混手牌
		Duel.ShuffleHand(tp)
		-- 将选中的怪兽表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果发动准备：设置掷硬币及可能发生的破坏操作信息
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：进行1次掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 检查自己场上是否存在可破坏的怪兽
	if Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)>0
		-- 检查对方场上是否存在可破坏的怪兽
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)>0 then
		-- 获取双方场上所有怪兽
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置连锁操作信息：破坏1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- ②效果处理：进行掷硬币（或判定结果），按表侧/里侧选择破坏己方/对方怪兽并给予攻击力数值伤害
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local res=-1
	-- 检查玩家是否受到「光之支配者」等可选择掷硬币结果的效果影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查自己场上是否存在怪兽
		local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在怪兽
		local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		if b1 and not b2 then
			-- 提示对方选定的掷硬币结果为表（正面）
			Duel.Hint(HINT_OPSELECTED,1-tp,SELECT_HEADS)
			res=1
		end
		if b2 and not b1 then
			-- 提示对方选定的掷硬币结果为里（背面）
			Duel.Hint(HINT_OPSELECTED,1-tp,SELECT_TAILS)
			res=0
		end
		if b1 and b2 then
			-- 让玩家从可选结果中选择正面或背面
			res=aux.SelectFromOptions(tp,
				{b1,SELECT_HEADS,1},
				{b2,SELECT_TAILS,0})
		end
	else
		-- 进行1次掷硬币
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 提示玩家选择要破坏的自己怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从自己场上选择1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 高亮显示选中的怪兽
			Duel.HintSelection(g)
			-- 检查怪兽原本攻击力有效性（判定是否具有攻击力数值）
			local flag=aux.covcheck(tc)
			-- 破坏选中的怪兽，成功时且该怪兽有原本攻击力则给予伤害
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and flag and tc:GetTextAttack()>0 then
				-- 给予自己该怪兽原本攻击力数值的伤害
				Duel.Damage(tp,tc:GetTextAttack(),REASON_EFFECT)
			end
		end
	elseif res==0 then
		-- 提示玩家选择要破坏的对方怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 高亮显示选中的怪兽
			Duel.HintSelection(g)
			-- 检查怪兽原本攻击力有效性（判定是否具有攻击力数值）
			local flag=aux.covcheck(tc)
			-- 破坏选中的怪兽，成功时且该怪兽有原本攻击力则给予伤害
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and flag and tc:GetTextAttack()>0 then
				-- 给予对方该怪兽原本攻击力数值的伤害
				Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
			end
		end
	end
end
