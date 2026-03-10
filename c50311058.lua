--百鬼羅刹大暴走
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的主要阶段才能发动。只用自己场上的「哥布林」怪兽为素材进行超量召唤。
-- ②：自己场上有「哥布林」超量怪兽存在的场合，以场上1只效果怪兽为对象才能发动。场上1个超量素材取除，作为对象的怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 创建场地魔法卡的发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己·对方的主要阶段才能发动。只用自己场上的「哥布林」怪兽为素材进行超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"超量召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「哥布林」超量怪兽存在的场合，以场上1只效果怪兽为对象才能发动。场上1个超量素材取除，作为对象的怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 筛选场上表侧表示的哥布林怪兽（非衍生物）
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and not c:IsType(TYPE_TOKEN)
end
-- 判断怪兽是否能使用指定素材进行超量召唤
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(mg)
end
-- 判断当前阶段是否为主要阶段1或主要阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 设置超量召唤效果的发动条件和目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上满足条件的哥布林怪兽组
		local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查是否存在可用的超量怪兽进行召唤
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	-- 设置连锁操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行超量召唤效果的操作流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上满足条件的哥布林怪兽组
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取可作为超量召唤素材的怪兽组
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 执行XYZ召唤手续，使用指定素材进行超量召唤
		Duel.XyzSummon(tp,xyz,g,1,6)
	end
end
-- 筛选场上表侧表示的哥布林超量怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_XYZ)
end
-- 判断场上是否存在哥布林超量怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在哥布林超量怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果无效化效果的目标选择和条件检查
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 目标选择时的过滤条件，确保目标为场上的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查是否能选择目标怪兽并移除一个超量素材
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上符合条件的效果怪兽作为目标
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行效果无效化操作，包括移除素材和设置无效效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否满足发动条件
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) then
		-- 从场上移除一个超量素材
		Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果在回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果在回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
