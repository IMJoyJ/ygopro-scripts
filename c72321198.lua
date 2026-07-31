--アルカナフォースⅩⅡ－THE HANGED MAN
local s,id,o=GetID()
-- 初始化卡片效果：注册手牌特召「秘仪之力」怪兽的诱发即时效果，以及召唤/特召/反转召唤成功时投掷硬币破坏怪兽并给予伤害的强制诱发效果
function s.initial_effect(c)
	-- ①：连锁发动时，把手卡的这张卡给对方观看才能发动。从手卡把1只「秘仪之力」怪兽表侧守备表示特殊召唤。
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
	-- ②：这张卡召唤·反转召唤·特殊召唤成功的场合发动。进行1次投掷硬币，根据正反面适用以下效果。
●表：选自己场上1只怪兽破坏，自己受到那只怪兽的原本攻击力数值的伤害。
●里：选对方场上1只怪兽破坏，对方受到那只怪兽的原本攻击力数值的伤害。
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
-- 手牌特召效果Cost：确认此卡在手牌未被公开
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 特召过滤条件：可以表侧守备表示特殊召唤的「秘仪之力」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 手牌特召效果准备：检查怪兽区域空位与手牌可特召怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在满足条件的「秘仪之力」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 手牌特召效果处理：从手牌把1只「秘仪之力」怪兽表侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足条件的「秘仪之力」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 洗混手牌
		Duel.ShuffleHand(tp)
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 硬币效果准备：设置硬币投掷及可能的怪兽破坏操作信息
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：进行1次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 检查自己场上是否存在怪兽
	if Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)>0
		-- 检查对方场上是否存在怪兽
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)>0 then
		-- 获取场上所有的怪兽
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 预先设置破坏怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- 硬币效果处理：进行硬币投掷（或受光之结界选择），根据结果破坏对应玩家场上的怪兽并造成原本攻击力伤害
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local res=-1
	-- 检查玩家是否受到「光之结界」的效果影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查己方场上是否存在可破坏的怪兽
		local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可破坏的怪兽
		local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		if b1 and not b2 then
			-- 向对方提示选择为正面
			Duel.Hint(HINT_OPSELECTED,1-tp,SELECT_HEADS)
			res=1
		end
		if b2 and not b1 then
			-- 向对方提示选择为反面
			Duel.Hint(HINT_OPSELECTED,1-tp,SELECT_TAILS)
			res=0
		end
		if b1 and b2 then
			-- 由玩家自行选择硬币正反面结果
			res=aux.SelectFromOptions(tp,
				{b1,SELECT_HEADS,1},
				{b2,SELECT_TAILS,0})
		end
	else
		-- 正常进行1次硬币投掷
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 提示玩家选择要破坏的己方怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从己方场上选择1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 高亮显示选择的怪兽
			Duel.HintSelection(g)
			-- 检查目标怪兽被破坏前是否在场
			local flag=aux.covcheck(tc)
			-- 破坏怪兽成功且原本攻击力大于0时继续处理伤害
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and flag and tc:GetTextAttack()>0 then
				-- 对己方造成破坏怪兽原本攻击力数值的伤害
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
			-- 高亮显示选择的怪兽
			Duel.HintSelection(g)
			-- 检查目标怪兽被破坏前是否在场
			local flag=aux.covcheck(tc)
			-- 破坏怪兽成功且原本攻击力大于0时继续处理伤害
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and flag and tc:GetTextAttack()>0 then
				-- 对对方造成破坏怪兽原本攻击力数值的伤害
				Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
			end
		end
	end
end
