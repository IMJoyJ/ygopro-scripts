--デビルドーザー
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只昆虫族怪兽从游戏中除外的场合才能特殊召唤。这张卡给与对方基本分战斗伤害时，从对方卡组最上面把1张卡送去墓地。
function c76039636.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己墓地2只昆虫族怪兽从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76039636.spcon)
	e1:SetTarget(c76039636.sptg)
	e1:SetOperation(c76039636.spop)
	c:RegisterEffect(e1)
	-- 这张卡给与对方基本分战斗伤害时，从对方卡组最上面把1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76039636,0))  --"对方卡组最上面把1张卡送去墓地"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c76039636.condition)
	e2:SetTarget(c76039636.target)
	e2:SetOperation(c76039636.operation)
	c:RegisterEffect(e2)
end
-- 过滤自身墓地中可以作为特殊召唤Cost除外的昆虫族怪兽
function c76039636.spfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定：检查怪兽区域是否有空位，以及墓地是否存在至少2只满足条件的昆虫族怪兽
function c76039636.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2张满足过滤条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c76039636.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤规则的准备操作：从墓地中选择2只昆虫族怪兽，并将其暂存
function c76039636.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c76039636.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作：将选中的2只昆虫族怪兽除外
function c76039636.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的理由表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查造成战斗伤害的对象是否为对方玩家
function c76039636.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标处理：设置将对方卡组最上面1张卡送去墓地的操作信息
function c76039636.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将对方卡组最上方的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
end
-- 效果执行：将对方卡组最上面1张卡送去墓地
function c76039636.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将对方卡组最上方的1张卡送去墓地
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
