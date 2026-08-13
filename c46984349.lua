--救魔の奇石
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽或者自己墓地1只怪兽除外才能把这张卡发动。这张卡发动后变成持有和除外的怪兽的原本等级相同等级的通常怪兽（魔法师族·光·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
function c46984349.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示怪兽或者自己墓地1只怪兽除外才能把这张卡发动。这张卡发动后变成持有和除外的怪兽的原本等级相同等级的通常怪兽（魔法师族·光·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46984349+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c46984349.cost)
	e1:SetTarget(c46984349.target)
	e1:SetOperation(c46984349.activate)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于筛选可作为发动代价的怪兽：必须是自己场上表侧表示或自己墓地的怪兽，且是等级1以上的怪兽并可以除外作为代价；同时除外后自己场上要有可用的怪兽区，并且当前能特殊召唤对应等级、攻/守0的魔法师族·光属性陷阱怪兽（即此卡变成的怪兽）。
function c46984349.costfilter(c,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsAbleToRemoveAsCost()
		-- 检查除外该代价怪兽后我方仍有可用怪兽区（Duel.GetMZoneCount(tp,c)>0），且玩家能够以‘救魔之奇石’的特殊召唤形态（魔法师族·光·攻/守0，等级为被除外怪兽原本等级）进行特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,46984349,0,TYPES_NORMAL_TRAP_MONSTER,0,0,c:GetOriginalLevel(),RACE_SPELLCASTER,ATTRIBUTE_LIGHT)
end
-- 支付代价：若存在满足条件的怪兽，则让玩家选择1张自己场上表侧表示或自己墓地的怪兽，将其表侧除外；并把该怪兽的原本等级存入效果标签，供特殊召唤时决定等级。
function c46984349.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：只判断场上或墓地中是否存在至少1张满足 costfilter 条件的怪兽可作为代价，不执行选择与除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c46984349.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家弹出‘请选择要除外的卡’的选择提示（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从符合条件的自己场上表侧表示怪兽或自己墓地怪兽中选出1张，作为发动代价要除外的卡。
	local g=Duel.SelectMatchingCard(tp,c46984349.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的那张卡以表侧表示除外（REASON_COST），完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
end
-- 目标处理：若代价已成功支付（IsCostChecked），则登记特殊召唤信息；本卡没有取对象目标，因此无需选择对象。
function c46984349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 向系统登记操作信息：本次连锁将在效果处理时将效果持有者（这张卡自身）进行特殊召唤，类别为特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：取出之前记录的代价怪兽原本等级；再次确认玩家仍能特殊召唤该陷阱怪兽；若能，则将这张卡变为通常怪兽（魔法师族·光·攻/守0，等级为记录值，同时保留陷阱类型），并特殊召唤到场上。
function c46984349.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 效果处理时的二次检查：若当前玩家不能再特殊召唤该陷阱怪兽（例如没有怪兽区或受到特殊召唤限制），则直接终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,46984349,0,TYPES_NORMAL_TRAP_MONSTER,0,0,lv,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,0,0,lv,0,0)
	-- 将已变成怪兽的这张卡以表侧表示特殊召唤到玩家自己场上；nocheck=true 表示不再检查召唤条件（前面已检查），nolimit=false 表示苏生限制等限制仍适用。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
