--空牙団の闘士 ブラーヴォ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的斗士 布拉沃」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合才能发动。场上的全部「空牙团」怪兽的攻击力·守备力直到回合结束时上升500。
function c66740005.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「空牙团的斗士 布拉沃」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66740005,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,66740005)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c66740005.sptg)
	e1:SetOperation(c66740005.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合才能发动。场上的全部「空牙团」怪兽的攻击力·守备力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66740005,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66740006)
	e2:SetCondition(c66740005.atkcon)
	e2:SetTarget(c66740005.atktg)
	e2:SetOperation(c66740005.atkop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中除「空牙团的斗士 布拉沃」以外且可以特殊召唤的「空牙团」怪兽
function c66740005.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(66740005) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检测与效果处理函数
function c66740005.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用于特殊召唤的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在至少1只满足过滤条件的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(c66740005.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的执行函数：从手牌特殊召唤1只「空牙团」怪兽
function c66740005.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上已没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足过滤条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c66740005.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示存在的「空牙团」怪兽
function c66740005.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 效果②的发动条件：自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合
function c66740005.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c66740005.cfilter,1,nil,tp)
end
-- 过滤场上表侧表示存在的「空牙团」怪兽
function c66740005.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 效果②的发动检测函数：检查场上是否存在至少1只表侧表示的「空牙团」怪兽
function c66740005.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查场上是否存在至少1只表侧表示的「空牙团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66740005.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果②的执行函数：使场上全部「空牙团」怪兽的攻击力·守备力直到回合结束时上升500
function c66740005.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的「空牙团」怪兽
	local tg=Duel.GetMatchingGroup(c66740005.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if tg:GetCount()>0 then
		local sc=tg:GetFirst()
		while sc do
			-- 攻击力……直到回合结束时上升500
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(500)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
			sc=tg:GetNext()
		end
	end
end
