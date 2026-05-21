--影依の炎核 ヴォイド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以对方场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「影依」怪兽从额外卡组送去墓地，作为对象的怪兽除外。
-- ②：这张卡被效果送去墓地的场合才能发动。把场上的怪兽的原本属性种类数量的卡从自己卡组上面送去墓地。
function c92079625.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「影依」怪兽从额外卡组送去墓地，作为对象的怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92079625,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92079625)
	e1:SetTarget(c92079625.target)
	e1:SetOperation(c92079625.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。把场上的怪兽的原本属性种类数量的卡从自己卡组上面送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92079625,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,92079625)
	e2:SetCondition(c92079625.tgcon)
	e2:SetTarget(c92079625.tgtg)
	e2:SetOperation(c92079625.tgop)
	c:RegisterEffect(e2)
	c92079625.shadoll_flip_effect=e1
end
-- 过滤对方场上表侧表示、可以被除外，且额外卡组存在与其相同属性的「影依」怪兽的怪兽
function c92079625.cfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		-- 检查额外卡组是否存在至少1只与该怪兽属性相同的「影依」怪兽
		and Duel.IsExistingMatchingCard(c92079625.tgfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetAttribute())
end
-- 过滤额外卡组中可以送去墓地、属性与指定属性相同且属于「影依」系列的怪兽
function c92079625.tgfilter(c,att)
	return c:IsAbleToGrave() and c:IsAttribute(att) and c:IsSetCard(0x9d)
end
-- ①号效果的发动准备与目标选择
function c92079625.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92079625.cfilter(chkc,tp) end
	-- 检查对方场上是否存在满足条件的表侧表示怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c92079625.cfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择对方场上1只满足条件的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92079625.cfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息：从额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果处理信息：将选中的对象怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①号效果的实际处理逻辑
function c92079625.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local att=tc:GetAttribute()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从额外卡组选择1只与对象怪兽属性相同的「影依」怪兽
		local g=Duel.SelectMatchingCard(tp,c92079625.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,att)
		-- 如果成功将选中的「影依」怪兽送去墓地
		if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 将作为对象的怪兽表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②号效果的发动条件：这张卡被效果送去墓地
function c92079625.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②号效果的发动准备
function c92079625.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方场上表侧表示怪兽的原本属性种类数量
	local ct=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetClassCount(Card.GetOriginalAttribute)
	-- 检查场上是否存在原本属性种类，且玩家是否能将对应数量的卡从卡组上面送去墓地
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置效果处理信息：从卡组上面将指定数量的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- ②号效果的实际处理逻辑
function c92079625.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算双方场上表侧表示怪兽的原本属性种类数量
	local ct=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetClassCount(Card.GetOriginalAttribute)
	-- 将该数量的卡从自己卡组上面送去墓地
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
end
