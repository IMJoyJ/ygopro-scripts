--EMエクストラ・シューター
-- 效果：
-- ←6 【灵摆】 6→
-- 「娱乐伙伴 额外射手」的灵摆效果1回合只能使用1次，这个效果发动的回合，自己不能灵摆召唤。
-- ①：自己主要阶段才能发动。给与对方为自己的额外卡组的表侧表示的灵摆怪兽数量×300伤害。
-- 【怪兽效果】
-- ①：1回合1次，从自己的额外卡组把1只怪兽除外，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，给与对方300伤害。
function c45591967.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其能作为灵摆卡在灵摆区域发动，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 【灵摆】「娱乐伙伴 额外射手」的灵摆效果1回合只能使用1次，这个效果发动的回合，自己不能灵摆召唤。①：自己主要阶段才能发动。给与对方为自己的额外卡组的表侧表示的灵摆怪兽数量×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45591967,0))  --"效果伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,45591967)
	e1:SetCost(c45591967.dmcost)
	e1:SetTarget(c45591967.dmtg)
	e1:SetOperation(c45591967.dmop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：1回合1次，从自己的额外卡组把1只怪兽除外，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45591967,1))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c45591967.descost)
	e2:SetTarget(c45591967.destg)
	e2:SetOperation(c45591967.desop)
	c:RegisterEffect(e2)
	-- 注册本卡专用的特殊召唤活动计数器（代号45591967），用于记录本回合是否进行过灵摆召唤；配合counterfilter，仅当发生灵摆召唤时计数加1，为灵摆效果的自肃提供判定。
	Duel.AddCustomActivityCounter(45591967,ACTIVITY_SPSUMMON,c45591967.counterfilter)
end
-- 计数器过滤函数：若特殊召唤的怪兽不是灵摆召唤则返回true（不计次数）；若是灵摆召唤则返回false（计数增加）。即该计数器专门记录灵摆召唤的发生。
function c45591967.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果的发动代价函数：判定本回合未进行过灵摆召唤后，给己方附加“不能灵摆召唤”的誓约效果，持续到回合结束，作为发动代价。
function c45591967.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方本回合灵摆召唤计数器是否为0，即尚未进行过灵摆召唤时，灵摆效果才满足发动条件。
	if chk==0 then return Duel.GetCustomActivityCount(45591967,tp,ACTIVITY_SPSUMMON)==0 end
	-- 【灵摆】「娱乐伙伴 额外射手」的灵摆效果1回合只能使用1次，这个效果发动的回合，自己不能灵摆召唤。①：自己主要阶段才能发动。给与对方为自己的额外卡组的表侧表示的灵摆怪兽数量×300伤害。【怪兽效果】①：1回合1次，从自己的额外卡组把1只怪兽除外，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，给与对方300伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45591967.splimit)
	-- 将“不能进行灵摆召唤”的誓约效果注册到场上，效果对象为己方玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：当一次特殊召唤的召唤方式为灵摆召唤时返回true，从而被上述“不能特殊召唤（灵摆召唤）”效果禁止。
function c45591967.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤函数：判断卡片是否为表侧表示且为灵摆怪兽，用于检索/计数额外卡组中符合条件的灵摆怪兽。
function c45591967.dmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 灵摆效果的发动目标处理：确认己方额外卡组存在表侧灵摆怪兽后，计算数量×300的伤害，将对象玩家设置为对方，并记录伤害参数与操作信息。
function c45591967.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方额外卡组是否存在至少1张表侧表示的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45591967.dmfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 计算伤害值：己方额外卡组表侧表示的灵摆怪兽数量×300。
	local dam=Duel.GetMatchingGroupCount(c45591967.dmfilter,tp,LOCATION_EXTRA,0,nil)*300
	-- 将当前连锁的对象玩家设置为对方（1-tp），表示伤害对象。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为计算出的伤害值dam。
	Duel.SetTargetParam(dam)
	-- 设置伤害效果的操作信息（对象玩家为对方，伤害值为dam），供连锁判定与效果记录使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 灵摆效果处理：从连锁信息中取得对象玩家，重新计算己方额外卡组表侧灵摆怪兽数量×300，并给予该玩家伤害。
function c45591967.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家（即受伤方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新计算伤害值（因为额外卡组状态可能在发动后变化）。
	local d=Duel.GetMatchingGroupCount(c45591967.dmfilter,tp,LOCATION_EXTRA,0,nil)*300
	-- 给予对象玩家计算出的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 怪兽效果的发动代价函数：需从自己的额外卡组选择1只可以除外的怪兽除外作为cost。
function c45591967.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方额外卡组是否存在至少1只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,1,nil) end
	-- 显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从己方额外卡组选择1张可以除外的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的卡表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 怪兽效果的发动目标处理：选择自己或对方灵摆区域的1张卡为对象，并设置破坏与伤害的操作信息。
function c45591967.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	-- 检查双方灵摆区域是否存在至少1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己或对方灵摆区域的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置破坏效果的操作信息，目标为选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害效果的操作信息，对对方造成300伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 怪兽效果处理：获得对象卡，若该卡仍与效果关联且被成功破坏，则给予对方300伤害。
function c45591967.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的怪兽效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联，并尝试以效果破坏；破坏成功时进入后续伤害处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给予对方玩家300点效果伤害。
		Duel.Damage(1-tp,300,REASON_EFFECT)
	end
end
