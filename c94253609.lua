--エレメンタル・アブソーバー
-- 效果：
-- 把手卡1张怪兽卡从游戏中除外。持有和这个效果除外的怪兽卡相同的属性的对方怪兽，只要这张卡在场上存在不能攻击宣言。
function c94253609.initial_effect(c)
	-- 把手卡1张怪兽卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c94253609.cost)
	c:RegisterEffect(e1)
	-- 持有和这个效果除外的怪兽卡相同的属性的对方怪兽，只要这张卡在场上存在不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c94253609.atktarget)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 过滤条件：手牌中可以作为代价除外的怪兽卡
function c94253609.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：将手牌1张怪兽卡除外，将该怪兽的属性记录到永续效果中，并在卡片上显示该属性提示
function c94253609.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以作为代价除外的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94253609.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1张满足过滤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c94253609.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡片作为代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local att=g:GetFirst():GetAttribute()
	e:GetLabelObject():SetLabel(att)
	e:GetHandler():SetHint(CHINT_ATTRIBUTE,att)
end
-- 限制攻击的目标过滤：检查怪兽的属性是否与记录的属性相同
function c94253609.atktarget(e,c)
	return c:IsAttribute(e:GetLabel())
end
