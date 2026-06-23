--カオス・ビースト－混沌の魔獣－
-- 效果：
-- 光属性调整＋调整以外的暗属性怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升1000。
-- ②：以除外的1只自己的光·暗属性怪兽为对象才能发动。那只怪兽加入手卡。
-- ③：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
local s,id,o=GetID()
-- 为卡片添加同调召唤手续，需要1只光属性调整和1只暗属性调整以外的怪兽作为素材；启用此卡的特殊召唤限制；创建并注册效果①，使此卡在回合中因除外而获得攻击力上升1000的效果；创建并注册效果②，以除外的光·暗属性怪兽为对象，将其加入手牌；创建并注册效果③，从手卡或墓地除外2只光·暗属性怪兽，将此卡从墓地特殊召唤。
function s.initial_effect(c)
	-- 添加同调召唤手续，需要1只光属性调整和1只暗属性调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- 效果①：这个回合是已有卡被除外的场合，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- 效果②：以除外的1只自己的光·暗属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 效果③：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置效果③的发动条件为：此卡不在送去墓地的回合。
	e3:SetCondition(aux.exccon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 创建一个全局持续效果，用于检测场上的除外事件，并在每次除外时记录标志。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册到游戏环境，使该效果对所有玩家生效。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有卡片被除外时，为玩家0注册一个标志效果，表示本轮已发生过除外事件。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家0注册一个标志效果，该效果在回合结束时重置，标记本轮已发生过除外事件。
	Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
end
-- 判断此卡是否在本轮中因除外而获得攻击力上升的效果触发条件。
function s.rmcon(e)
	-- 如果玩家0的id标志效果数量大于0，则表示本轮已发生过除外事件。
	return Duel.GetFlagEffect(0,id)>0
end
-- 定义用于筛选目标的过滤函数，要求目标为表侧表示、光·暗属性且能加入手牌的怪兽。
function s.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 设置效果②的目标选择处理，检查是否有满足条件的目标存在，并提示玩家选择目标。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	-- 检查是否满足效果②的发动条件，即是否存在满足条件的除外怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家提示“请选择要加入手牌的卡”以选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的除外怪兽作为效果②的目标。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果②的操作信息，表示将目标怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果②的操作，将选中的目标怪兽加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义用于筛选除外成本的过滤函数，要求目标为光·暗属性且能除外。
function s.costfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 设置效果③的成本处理，检查是否有满足条件的2张卡组成组合并选择它们除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手卡和墓地中的所有满足条件的怪兽作为除外成本候选。
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler())
	-- 检查是否满足效果③的发动条件，即是否存在满足条件的2张卡组成的组合。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 向玩家提示“请选择要除外的卡”以选择除外成本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选中选择满足条件的2张卡组成组合并除外作为发动成本。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选中的卡组以效果原因除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 设置效果③的目标处理，检查是否满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的位置进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果③的操作信息，表示将此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果③的操作，将此卡从墓地特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以特殊召唤方式送入场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
