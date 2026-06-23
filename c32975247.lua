--神竜 ティタノマキア
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：特殊召唤的这张卡不会被战斗破坏。
-- ②：从自己墓地以及自己场上的表侧表示怪兽之中把包含场上的这张卡的3只「神龙 伟战龙」除外才能发动。对方场上的卡全部破坏。
-- ③：自己·对方的结束阶段才能发动。把自己场上的龙族怪兽数量的卡从自己卡组上面送去墓地。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：①不被战斗破坏、②除外3只神龙伟战龙破坏对方场上所有卡、③结束阶段将场上龙族怪兽数量的卡从卡组送去墓地
function c32975247.initial_effect(c)
	-- ①：特殊召唤的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c32975247.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：从自己墓地以及自己场上的表侧表示怪兽之中把包含场上的这张卡的3只「神龙 伟战龙」除外才能发动。对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32975247,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32975247)
	e2:SetCost(c32975247.descost)
	e2:SetTarget(c32975247.destg)
	e2:SetOperation(c32975247.desop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。把自己场上的龙族怪兽数量的卡从自己卡组上面送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32975247,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,32975247+o)
	e3:SetTarget(c32975247.distg)
	e3:SetOperation(c32975247.disop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：此卡必须为特殊召唤
function c32975247.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果②的除外卡筛选函数：筛选卡号为32975247且可作为除外费用的卡，且必须在墓地或场上正面表示
function c32975247.costfilter(c)
	return c:IsCode(32975247) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果②的发动费用：选择2张符合条件的卡和自身共3张卡除外
function c32975247.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取满足除外条件的卡组（包括墓地和场上正面表示的神龙伟战龙）
	local g=Duel.GetMatchingGroup(c32975247.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c)
	if chk==0 then return c:IsAbleToRemoveAsCost() and g:GetCount()>=2 end
	local sg
	if #g==2 then
		sg=g
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		sg=g:Select(tp,2,2,nil)
	end
	sg:AddCard(c)
	-- 将选中的卡除外作为发动费用
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果②的发动目标设定：确认对方场上存在卡
function c32975247.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果②的处理信息：破坏对方场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的发动效果：破坏对方场上所有卡
function c32975247.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 执行破坏对方场上所有卡的效果
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果③的筛选函数：筛选场上正面表示的龙族怪兽
function c32975247.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果③的发动目标设定：确认自己可以将卡组顶部的卡送去墓地
function c32975247.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算场上正面表示的龙族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c32975247.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查自己是否可以将指定数量的卡从卡组顶部送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置效果③的处理信息：将指定数量的卡从卡组顶部送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 效果③的发动效果：将场上龙族怪兽数量的卡从卡组顶部送去墓地
function c32975247.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算场上正面表示的龙族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c32975247.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		-- 将场上龙族怪兽数量的卡从卡组顶部送去墓地
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	end
end
