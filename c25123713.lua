--空牙団の豪傑 ダイナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。选最多有自己场上的「空牙团」怪兽种类数量的对方墓地的卡除外。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他的「空牙团」怪兽作为攻击对象。
function c25123713.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。选最多有自己场上的「空牙团」怪兽种类数量的对方墓地的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,25123713)
	e1:SetTarget(c25123713.rmtg)
	e1:SetOperation(c25123713.rmop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他的「空牙团」怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c25123713.atlimit)
	c:RegisterEffect(e2)
end
-- 用于筛选场上正面表示的「空牙团」怪兽
function c25123713.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 效果发动时的条件判断，检查我方场上是否存在「空牙团」怪兽且对方墓地存在可除外的卡
function c25123713.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方场上正面表示的「空牙团」怪兽组
	local g=Duel.GetMatchingGroup(c25123713.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:GetCount()~=0
		-- 检查对方墓地是否存在至少一张可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置连锁操作信息，指定将要除外的卡的来源为对方墓地
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理函数，计算我方场上「空牙团」怪兽数量并选择相应数量的对方墓地卡除外
function c25123713.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方场上正面表示的「空牙团」怪兽组
	local cg=Duel.GetMatchingGroup(c25123713.filter,tp,LOCATION_MZONE,0,nil)
	local ct=cg:GetClassCount(Card.GetCode)
	if ct==0 then return end
	-- 向玩家提示选择除外卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地中选择最多与我方「空牙团」怪兽数量相同的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选中的卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 限制对方不能选择「空牙团」怪兽作为攻击对象
function c25123713.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x114) and c~=e:GetHandler()
end
