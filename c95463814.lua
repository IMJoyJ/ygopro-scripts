--幻魔帝トリロジーグ
-- 效果：
-- 10星怪兽×3
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合或者这张卡已在怪兽区域存在的状态有这张卡以外的怪兽从墓地往自己场上特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
function c95463814.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为10星怪兽×3
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsLevel,10),3,true)
	-- ①：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95463814,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,95463814)
	e1:SetTarget(c95463814.target)
	e1:SetOperation(c95463814.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c95463814.contition2)
	c:RegisterEffect(e2)
end
-- 过滤对方场上表侧表示且原本攻击力大于0的怪兽
function c95463814.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- 效果①的发动准备与目标选择
function c95463814.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c95463814.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c95463814.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95463814.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为给与对方该怪兽原本攻击力一半数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetBaseAttack()/2))
end
-- 效果①的效果处理（给与伤害）
function c95463814.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给与对方该怪兽原本攻击力一半数值的伤害
		Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
-- 过滤从墓地特殊召唤到自己场上的怪兽
function c95463814.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
-- 检查是否有这张卡以外的怪兽从墓地往自己场上特殊召唤
function c95463814.contition2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(c95463814.cfilter,1,nil,tp)
end
