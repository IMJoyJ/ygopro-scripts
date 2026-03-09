--葬世の神 デーヴァリーム
-- 效果：
-- 这张卡不能通常召唤。「葬世之神 德瓦里姆」1回合1次在把攻击力或守备力是2500的自己墓地2只怪兽除外的场合才能从墓地特殊召唤。
-- ①：这张卡特殊召唤的场合，以最多有攻击力或守备力是2500的自己的除外状态的怪兽数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。
-- ②：对方场上的怪兽的攻击力只在战斗阶段内下降2500。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片的特殊召唤限制、特殊召唤条件、效果触发和攻击力变更效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 「葬世之神 德瓦里姆」1回合1次在把攻击力或守备力是2500的自己墓地2只怪兽除外的场合才能从墓地特殊召唤。
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
	-- ①：这张卡特殊召唤的场合，以最多有攻击力或守备力是2500的自己的除外状态的怪兽数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。
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
-- 过滤函数，用于筛选攻击力或守备力为2500且可作为除外费用的墓地怪兽
function s.sprfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件函数，检查是否满足特殊召唤所需条件（场上空位+墓地2只2500怪兽）
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家墓地是否存在至少2只攻击力或守备力为2500的怪兽
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler())
end
-- 特殊召唤目标选择函数，从墓地中选择2只符合条件的怪兽除外
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的墓地怪兽数组
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤执行函数，将选中的怪兽除外并完成特殊召唤
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽以除外形式移除（REASON_SPSUMMON）
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于筛选攻击力或守备力为2500且处于表侧表示的除外怪兽
function s.cfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsFaceupEx()
end
-- 效果①的目标选择函数，根据除外的2500怪兽数量决定可选目标数量
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 计算当前玩家除外状态中攻击力或守备力为2500的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,0,nil)
	-- 检查是否满足效果发动条件（有目标且存在可返回手牌的目标）
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 使用辅助函数优先从场上选择目标，不足时再从墓地选择
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	-- 设置操作信息，记录将要处理的回手牌效果对象数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果①的执行函数，将符合条件的目标送回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与连锁相关的选中目标，并过滤受王家长眠之谷影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将目标卡送回手牌（REASON_EFFECT）
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 判断是否处于战斗阶段
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为战斗阶段
	return Duel.IsBattlePhase()
end
