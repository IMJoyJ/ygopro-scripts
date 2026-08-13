--炎獄魔人ヘル・バーナー
-- 效果：
-- 不把除这张卡外的自己手卡全部丢弃去墓地，并用自己场上1只攻击力2000以上的怪兽作为祭品不能通常召唤。对方场上每存在1只怪兽，这张卡的攻击力上升200。自己场上这张卡以外的怪兽每存在1只，这张卡的攻击力下降500。
function c23309606.initial_effect(c)
	-- 对应效果原文：不把除这张卡外的自己手卡全部丢弃去墓地，并用自己场上1只攻击力2000以上的怪兽作为祭品不能通常召唤。
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
	-- 对应效果原文：对方场上每存在1只怪兽，这张卡的攻击力上升200。自己场上这张卡以外的怪兽每存在1只，这张卡的攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c23309606.val)
	c:RegisterEffect(e3)
end
-- 祭品候选过滤：筛选攻击力在2000以上，且满足“是自己控制的怪兽（任意表示形式）或对方场上的表侧表示怪兽”这一条件的怪兽，作为可选的祭品对象。
function c23309606.otfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断能否进行该规则召唤：需要手牌中存在这张卡以外的卡、本次召唤所需祭品数不超过1、候选祭品中存在1只可用的祭品，并且手牌中除这张卡外的所有卡都能作为代价送去墓地。
function c23309606.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得该玩家手牌中的所有卡片，此卡组随后会排除要召唤的这张卡本身。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(c)
	-- 获取双方主要怪兽区中攻击力2000以上且满足otfilter条件的怪兽，作为祭品候选组。
	local mg=Duel.GetMatchingGroup(c23309606.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查召唤条件的一部分：除这张卡外的手牌数大于0、所需祭品数不超过1，并且候选组中存在可用的1只祭品。
	return hg:GetCount()>0 and minc<=1 and Duel.CheckTribute(c,1,1,mg)
		and hg:FilterCount(Card.IsAbleToGraveAsCost,nil)==hg:GetCount()
end
-- 执行召唤手续：将手牌中这张卡以外的全部卡丢弃去墓地，再从候选祭品中选择1只攻击力2000以上的怪兽作为祭品解放，完成召唤所需的额外代价。
function c23309606.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 取得该玩家手牌中的所有卡片，后续会从中移除这张卡本身并全部丢弃。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(c)
	-- 将手牌中除这张卡外的所有卡作为召唤代价丢弃去墓地（同时带有COST和DISCARD原因）。
	Duel.SendtoGrave(hg,REASON_COST+REASON_DISCARD)
	-- 再次获取双方主要怪兽区中攻击力2000以上且满足otfilter条件的怪兽，作为实际选择祭品时的候选组。
	local mg=Duel.GetMatchingGroup(c23309606.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从候选祭品组中选择1只怪兽，作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的那只祭品怪兽作为召唤素材解放，完成上级召唤所需的解放手续。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 计算这张卡的攻击力增减值：对方场上的怪兽数×200上升，自己场上（含这张卡）的怪兽数×-500后再加上500，等效为自己场上这张卡以外的每只怪兽使攻击力下降500。
function c23309606.val(e,c)
	local tp=c:GetControler()
	-- 返回攻击力修正值：对方场上怪兽数量×200，减去（自己场上怪兽数量-1）×500，即对方每有1只怪兽上升200，自己场上其他每有1只怪兽下降500。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*-500+500+Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*200
end
