--シューティング・クェーサー・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的攻击。
-- ②：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ③：表侧表示的这张卡从场上离开时才能发动。从额外卡组把1只「流星龙」特殊召唤。
function c35952884.initial_effect(c)
	-- 为这张卡添加同调召唤手续，素材要求为：同调怪兽调整＋调整以外的同调怪兽2只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤限制效果的值设为aux.synlimit，使这张卡仅能通过同调召唤方式特殊召唤，不能用其他方式特殊召唤。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c35952884.valcheck)
	c:RegisterEffect(e3)
	-- ②：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35952884,0))  --"效果无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c35952884.discon)
	e3:SetTarget(c35952884.distg)
	e3:SetOperation(c35952884.disop)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡从场上离开时才能发动。从额外卡组把1只「流星龙」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35952884,1))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c35952884.sumcon)
	e4:SetTarget(c35952884.sumtg)
	e4:SetOperation(c35952884.sumop)
	c:RegisterEffect(e4)
end
c35952884.material_type=TYPE_SYNCHRO
c35952884.cosmic_quasar_dragon_summon=true
-- 同调召唤成功时计算素材中除调整怪兽以外的数量（素材数-1），若该数量大于1，则给这张卡赋予额外攻击次数效果。
function c35952884.valcheck(e,c)
	local ct=c:GetMaterialCount()-1
	if ct>1 then
		-- ①：这张卡在同1次的战斗阶段中可以作出最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：此卡没有被战斗破坏，且当前发动的效果可以被无效。
function c35952884.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡不是被战斗破坏状态，且当前连锁可以被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ②效果的发动目标处理：若在效果发动时确认，则设置要无效的对象为当前发动的效果；若对应卡仍可被破坏且与发动效果关联，则同时设置破坏对象。
function c35952884.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含“无效发动”，对象为当前发动的效果（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次效果包含“破坏”，对象为当前发动的效果对应卡（eg），数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：若成功无效该效果的发动，且对应卡仍未离场并与之关联，则将其破坏。
function c35952884.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该发动，且发动效果的那张卡仍与效果相关联（没有因连锁失去联系）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将无效掉发动的那张卡（eg）以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡曾表侧表示存在于场上，并且从场上离开。
function c35952884.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义可特殊召唤的卡：卡号为24696097（「流星龙」），能被当前效果特殊召唤，且额外卡组怪兽有可用的特殊召唤区域。
function c35952884.filter(c,e,tp)
	-- 确认目标卡是「流星龙」、满足特殊召唤条件，并且有足够的空位从额外卡组特殊召唤。
	return c:IsCode(24696097) and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ③效果发动目标处理：若效果发动时检查到额外卡组存在符合条件的「流星龙」，则设置从额外卡组特殊召唤1只「流星龙」的操作信息。
function c35952884.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查额外卡组是否有至少1只满足条件的「流星龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c35952884.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行从额外卡组特殊召唤1只怪兽，目标在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果处理：从额外卡组选取符合条件的「流星龙」，将其特殊召唤到场上。
function c35952884.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 从额外卡组取得第一张符合条件的「流星龙」（发动时确认存在，处理时再取）。
	local tg=Duel.GetFirstMatchingCard(c35952884.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将选中的「流星龙」以表侧表示特殊召唤到自己场上（不检查苏生限制，不检查特殊召唤条件）。
		Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP)
	end
end
