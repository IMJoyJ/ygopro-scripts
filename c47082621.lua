--葬世の神 デーヴァリーム
-- 效果：
-- 这张卡不能通常召唤。「葬世之神 德瓦里姆」1回合1次在把攻击力或守备力是2500的自己墓地2只怪兽除外的场合才能从墓地特殊召唤。
-- ①：这张卡特殊召唤的场合，以最多有攻击力或守备力是2500的自己的除外状态的怪兽数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。
-- ②：对方场上的怪兽的攻击力只在战斗阶段内下降2500。
local s,id,o=GetID()
-- 注册此卡无法通常召唤、以墓地2只攻守为2500的怪兽除外作为条件特召自身、特召成功回收对方场上墓地卡片、以及战斗阶段对方场上降攻2500的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册此卡不能通过通常召唤或常规特殊召唤出场、只能通过特定的召唤规程特殊召唤的规则
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 注册通过将自己墓地2只攻击力或守备力是2500的怪兽除外，从而从墓地特殊召唤自身的规程
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以最多有攻击力或守备力是2500的自己的除外状态的怪兽数量的对方场上·墓地的卡为对象才能发动。那些卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：对方场上的怪兽的攻击力只在战斗阶段内下降2500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(-2500)
	c:RegisterEffect(e3)
end
-- 墓地中攻击力或守备力为2500且能够除外作为召唤Cost的怪兽过滤条件
function s.sprfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsAbleToRemoveAsCost()
end
-- 判断此卡从墓地特殊召唤的可行性
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有空闲的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中除了此卡以外，是否存在至少2只攻守为2500的怪兽
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler())
end
-- 向玩家提示并从墓地中选择2只攻守为2500的怪兽进行除外
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地符合条件的怪兽组以供选择
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 向玩家发送提示，请选择除外作为特召Cost的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行将选定怪兽除外的特殊召唤Cost处理
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的2只怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 自己除外状态中，攻击力或守备力为2500且处于表侧表示的怪兽的过滤条件
function s.cfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsFaceupEx()
end
-- 弹回对方场上/墓地卡片效果的发动准备与对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 计算自己除外状态中攻守为2500的怪兽的总数量，以此作为选择对方卡片的最大上限
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,0,nil)
	-- 检查对方场上或墓地是否存在可以被返回手牌的卡片
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示，请选择要弹回的对方卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上或墓地中选择最多与上述除外怪兽等量的卡片作为回收对象
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	-- 设置操作信息为将所选卡片返回持有者手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 将对方场上或墓地的卡片送回手牌的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联且未受墓地无效影响的作为对象的卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将这些被选中的卡片送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 判断当前是否处于战斗阶段内
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若是则适用降低对方场上怪兽攻击力的效果
	return Duel.IsBattlePhase()
end
