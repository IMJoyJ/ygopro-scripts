--ボルテック・コング
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，把自己场上表侧表示存在的光属性怪兽数量的卡从对方卡组上面送去墓地。
function c93151201.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，把自己场上表侧表示存在的光属性怪兽数量的卡从对方卡组上面送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93151201,0))  --"卡组送墓"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c93151201.condition)
	e2:SetTarget(c93151201.target)
	e2:SetOperation(c93151201.operation)
	c:RegisterEffect(e2)
end
-- 判断受到战斗伤害的是否为对方玩家
function c93151201.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤自己场上表侧表示的光属性怪兽
function c93151201.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果发动的目标确认，计算符合条件的怪兽数量并设置卡组送墓的操作信息
function c93151201.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己场上表侧表示的光属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(c93151201.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置将对方卡组最上方对应数量的卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,ct)
end
-- 效果处理，计算符合条件的怪兽数量并将对应数量的卡从对方卡组上面送去墓地
function c93151201.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算效果处理时自己场上表侧表示的光属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(c93151201.filter,tp,LOCATION_MZONE,0,nil)
	-- 将对方卡组最上方对应数量的卡送去墓地
	Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
end
