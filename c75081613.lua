--ジャイアントワーム
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的1只昆虫族怪兽从游戏中除外的场合才能特殊召唤。这张卡给与对方基本分战斗伤害时，从对方卡组上面把1张卡送去墓地。
function c75081613.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己墓地存在的1只昆虫族怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c75081613.spcon)
	e2:SetTarget(c75081613.sptg)
	e2:SetOperation(c75081613.spop)
	c:RegisterEffect(e2)
	-- 这张卡给与对方基本分战斗伤害时，从对方卡组上面把1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75081613,0))  --"卡组送墓"
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c75081613.condition)
	e3:SetTarget(c75081613.target)
	e3:SetOperation(c75081613.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的昆虫族怪兽
function c75081613.spfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件：检查怪兽区域是否有空位，且墓地是否存在至少1只可除外的昆虫族怪兽
function c75081613.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c75081613.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的卡片选择：从墓地中选择1只昆虫族怪兽，并将其暂存
function c75081613.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c75081613.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行：将选择的怪兽除外，完成特殊召唤
function c75081613.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 触发条件：造成战斗伤害的玩家是对方（即自己给与对方战斗伤害）
function c75081613.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动准备：设置卡组送墓的操作信息
function c75081613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果会将对方卡组最上方的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
end
-- 效果处理：将对方卡组最上方的1张卡送去墓地
function c75081613.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将对方卡组最上方的1张卡送去墓地
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
