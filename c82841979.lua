--大和神
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的1只灵魂怪兽从游戏中除外的场合才能特殊召唤。特殊召唤的回合的结束阶段时回到持有者手卡。这张卡战斗破坏对方怪兽的场合，可以把对方场上存在的1张魔法或者陷阱卡破坏。
function c82841979.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册灵魂怪兽在特殊召唤成功的回合的结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SPSUMMON_SUCCESS)
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己墓地存在的1只灵魂怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c82841979.spcon)
	e2:SetTarget(c82841979.sptg)
	e2:SetOperation(c82841979.spop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏对方怪兽的场合，可以把对方场上存在的1张魔法或者陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82841979,0))  --"返回手牌"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件为这张卡与对方怪兽战斗并将其破坏
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(c82841979.destg)
	e4:SetOperation(c82841979.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：墓地中的灵魂怪兽，且可以作为Cost除外
function c82841979.spfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定：怪兽区域有空位，且墓地存在至少1只满足条件的灵魂怪兽
function c82841979.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己墓地是否存在至少1只满足过滤条件的灵魂怪兽
		Duel.IsExistingMatchingCard(c82841979.spfilter,c:GetControler(),LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的目标选择：让玩家选择1只墓地的灵魂怪兽作为除外对象
function c82841979.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的灵魂怪兽
	local g=Duel.GetMatchingGroup(c82841979.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作：将选中的灵魂怪兽除外
function c82841979.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的灵魂怪兽以特殊召唤的Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤条件：魔法或陷阱卡
function c82841979.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标选择：选择对方场上1张魔法或陷阱卡作为效果对象
function c82841979.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c82841979.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c82841979.filter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c82841979.filter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的具体处理：破坏选中的魔法或陷阱卡
function c82841979.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选中的第一个对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏选中的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
