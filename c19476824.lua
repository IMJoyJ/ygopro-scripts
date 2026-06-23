--メタファイズ・ラグナロク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己卡组上面把3张卡除外。这张卡的攻击力上升这个效果除外的「玄化」卡数量×300。
-- ②：这张卡给与对方战斗伤害时才能发动。从卡组把1只5星以上的「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
function c19476824.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19476824,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19476824)
	e1:SetTarget(c19476824.rmtg)
	e1:SetOperation(c19476824.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡给与对方战斗伤害时才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19476824,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1,19476825)
	e3:SetCondition(c19476824.spcon)
	e3:SetTarget(c19476824.sptg)
	e3:SetOperation(c19476824.spop)
	c:RegisterEffect(e3)
end
-- 检查卡组顶部3张卡是否都能除外
function c19476824.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组最上方的3张卡
	local rg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==3 end
	-- 设置将要除外的3张卡作为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,0,0)
end
-- 处理卡组顶部3张卡的除外效果
function c19476824.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if #g<=0 then return end
	-- 禁止接下来的除外操作检查洗牌
	Duel.DisableShuffleCheck()
	-- 将顶部3张卡除外
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取实际被除外的卡
		local og=Duel.GetOperatedGroup()
		local oc=og:FilterCount(Card.IsSetCard,nil,0x105)
		if oc==0 then return end
		-- 将攻击力提升这个效果除外的「玄化」卡数量×300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(oc*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 确认战斗伤害是由对方造成的
function c19476824.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 筛选卡组中满足「玄化」且等级5以上的怪兽
function c19476824.spfilter(c,e,tp)
	return c:IsSetCard(0x105) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查卡组中是否存在满足条件的怪兽
function c19476824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c19476824.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置将要特殊召唤的怪兽作为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理从卡组特殊召唤怪兽的效果
function c19476824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local tc=Duel.SelectMatchingCard(tp,c19476824.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(19476824,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册一个在下个回合结束时除外该怪兽的效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置该效果在下个回合结束时触发
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c19476824.descon)
		e2:SetOperation(c19476824.desop)
		-- 将该效果注册到玩家全局环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否到了该效果应触发的回合
function c19476824.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(19476824)~=0 then
		-- 判断当前回合数是否等于设定的回合数
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 处理将怪兽除外的效果
function c19476824.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
