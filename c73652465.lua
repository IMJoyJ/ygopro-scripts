--BF－突風のオロシ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「黑羽-突风之颪」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
function c73652465.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「黑羽-突风之颪」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,73652465+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c73652465.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73652465,0))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c73652465.condition)
	e2:SetTarget(c73652465.target)
	e2:SetOperation(c73652465.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「黑羽-突风之颪」以外的「黑羽」怪兽
function c73652465.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(73652465)
end
-- 规则特殊召唤的发动条件：自身控制者的主要怪兽区域有空位，且场上存在满足过滤条件的怪兽
function c73652465.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c73652465.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 触发条件：这张卡在墓地存在，且作为同调素材送去墓地
function c73652465.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤条件：可以变更表示形式的怪兽
function c73652465.posfilter(c)
	return c:IsCanChangePosition()
end
-- 效果②的靶向处理：检查场上是否存在可变更表示形式的怪兽，并选择其中1只作为效果对象，设置操作信息为变更表示形式
function c73652465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c73652465.posfilter(chkc) end
	-- 检查场上（双方怪兽区域）是否存在至少1只可以变更表示形式的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c73652465.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要变更表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择1只可以变更表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73652465.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为：变更所选对象怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的执行处理：将选择的对象怪兽的表示形式变更
function c73652465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更目标怪兽的表示形式（表侧守备、里侧守备、表侧攻击之间切换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
