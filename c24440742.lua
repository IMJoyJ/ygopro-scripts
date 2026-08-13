--影帽子
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（幻想魔族·暗·4星·攻1500/守600）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●这张卡特殊召唤的场合，以最多有自己场上的幻想魔族怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ●这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化本卡效果：e1为发动后特殊召唤为陷阱怪兽的起动效果；e2为特殊召唤成功时无效对方表侧卡片的诱发效果；e3为自身与怪兽战斗时双方不会被战斗破坏的永续效果。
function s.initial_effect(c)
	-- 这张卡发动后变成持有以下效果的效果怪兽（幻想魔族·暗·4星·攻1500/守600）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合，以最多有自己场上的幻想魔族怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.con)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 发动条件的检查：确认没有其他cost限制、自己场上怪兽区域有空位，且自己可以把这张卡作为幻想魔族·暗·4星·攻1500/守600的效果怪兽特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己怪兽区域是否有空位可供特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己可以用本卡效果将这张卡作为幻想魔族·暗·4星·攻1500/守600的陷阱怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1500,600,4,RACE_ILLUSION,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次操作包含特殊召唤这张卡（CATEGORY_SPECIAL_SUMMON），目标为自己场上的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡变为效果怪兽（陷阱怪兽）并在自己的怪兽区域表侧攻击表示特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己仍能特殊召唤该陷阱怪兽，若不能则直接终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1500,600,4,RACE_ILLUSION,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果将该卡作为陷阱怪兽特殊召唤到自己的怪兽区域，表示形式为表侧表示，并记录召唤方式为自身效果（SUMMON_VALUE_SELF）。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 效果发动条件：判断本卡是否以自身效果（SUMMON_VALUE_SELF）特殊召唤成功。
function s.con(e)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数：判断卡片是否表侧表示且种族为幻想魔族，用于统计自己场上幻想魔族怪兽数量。
function s.filter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsFaceup()
end
-- 无效效果的目标选择：统计自己场上表侧幻想魔族怪兽的数量作为可选上限，从对方场上表侧表示且可以被无效的卡中选择1至该数量的卡片。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上表侧表示的幻想魔族怪兽数量，决定最多可选卡数。
	local ct=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(s.filter,nil)
	-- 若是在连锁处理中选择对象时，确认对象在场上、对方控制且可以被无效，否则不能选择。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 发动时确认对方场上有至少1张表侧表示且可以被无效的卡，并且自己幻想魔族怪兽数量大于0。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 给操作者显示选择提示：请选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方场上表侧且可无效的卡中选择1到‘自己幻想魔族怪兽数量’张作为效果对象，并记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：本次操作将无效所选择的卡片（CATEGORY_DISABLE），数量为所选卡数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 无效效果处理：对仍与自己效果相关且表侧表示的对象卡，无效其效果，并对陷阱怪兽额外适用陷阱怪兽无效化效果，直到回合结束。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中与效果相关的所有对象卡片。
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历所有连锁对象，逐一处理无效化。
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与该卡片相关的连锁（如场上发动的效果）无效化，直到回合结束。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 战斗破坏耐性判定：当这张卡与怪兽进行战斗时，这张卡及其战斗对象（对方怪兽）都不会被那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
