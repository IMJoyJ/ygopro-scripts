--炎獄魔人ヘル・バーナー
-- 效果：
-- 不把除这张卡外的自己手卡全部丢弃去墓地，并用自己场上1只攻击力2000以上的怪兽作为祭品不能通常召唤。对方场上每存在1只怪兽，这张卡的攻击力上升200。自己场上这张卡以外的怪兽每存在1只，这张卡的攻击力下降500。
function c23309606.initial_effect(c)
	-- 不把除这张卡外的自己手卡全部丢弃去墓地，并用自己场上1只攻击力2000以上的怪兽作为祭品不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23309606,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c23309606.otcon)
	e1:SetOperation(c23309606.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	-- 自己场上这张卡以外的怪兽每存在1只，这张卡的攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c23309606.val)
	c:RegisterEffect(e3)
end
-- 过滤场上攻击力2000以上的怪兽，包括自己控制的和表侧表示的怪兽。
function c23309606.otfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足通常召唤的条件：手牌不为空、最小召唤数量不超过1、场上存在满足条件的祭品、手牌全部可以作为代价送去墓地。
function c23309606.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家手牌组。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(c)
	-- 获取玩家场上攻击力2000以上的怪兽组。
	local mg=Duel.GetMatchingGroup(c23309606.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断手牌数量大于0、最小召唤数量不超过1、场上存在满足条件的祭品。
	return hg:GetCount()>0 and minc<=1 and Duel.CheckTribute(c,1,1,mg)
		and hg:FilterCount(Card.IsAbleToGraveAsCost,nil)==hg:GetCount()
end
-- 处理通常召唤的费用：将手牌全部送去墓地，选择并解放1只场上怪兽作为祭品。
function c23309606.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取玩家手牌组。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(c)
	-- 将手牌全部送去墓地作为召唤代价。
	Duel.SendtoGrave(hg,REASON_COST+REASON_DISCARD)
	-- 获取玩家场上攻击力2000以上的怪兽组。
	local mg=Duel.GetMatchingGroup(c23309606.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只场上怪兽作为祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为召唤代价。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 计算攻击力变化值：自己场上怪兽数量乘以-500再加上500，再加上对方场上怪兽数量乘以200。
function c23309606.val(e,c)
	local tp=c:GetControler()
	-- 返回攻击力变化值，计算公式为：自己场上怪兽数量乘以-500再加上500，再加上对方场上怪兽数量乘以200。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*-500+500+Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*200
end
