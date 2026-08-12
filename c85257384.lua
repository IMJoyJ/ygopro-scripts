--幻影騎士団アンブレイジベイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。自己的场上或墓地有「幻影骑士团」怪兽存在的场合，这张卡在盖放的回合也能发动。
-- ①：这张卡发动后变成通常怪兽（战士族·暗·3星·攻0/守300）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。那之后，可以把对方场上1只攻击表示怪兽变成守备表示。
-- ②：把墓地的这张卡除外才能发动。进行1只暗属性超量怪兽的超量召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①的卡片发动、效果②的墓地除外超量召唤，以及符合条件时在盖放回合发动的效果③。
function s.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（战士族·暗·3星·攻0/守300）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。那之后，可以把对方场上1只攻击表示怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。进行1只暗属性超量怪兽的超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 效果②的Cost（代价）：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	-- 自己的场上或墓地有「幻影骑士团」怪兽存在的场合，这张卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"适用「幻影骑士团 本影烈焰剑苍骑」的效果来发动"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件与靶向判定：检查己方主要怪兽区域是否有空位，以及是否可以将本卡作为陷阱怪兽特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 效果①判定的一部分：检查己方主要怪兽区域是否拥有可用的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果①判定的一部分：检查玩家是否可以把本卡作为怪兽（战士族·暗·3星·攻0/守300）特殊召唤到己方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,300,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置效果①处理时的操作信息：预计将本卡在主要怪兽区域特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤对方场上表侧攻击表示且可以改变表示形式的怪兽。
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果①的执行操作：把本卡作为通常怪兽特殊召唤到己方场上。之后，如果对方场上存在表侧攻击表示怪兽，玩家可以选择将对方场上的1只攻击表示怪兽变成守备表示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时：判断本卡是否依然和连锁关联，并且是否仍然可以作为怪兽特殊召唤。
	if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,300,3,RACE_WARRIOR,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将本卡在己方主要怪兽区守备表示特殊召唤成功后，进行下一步处理。
		if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)~=0
			-- 效果处理时后续判定的第一步：检查对方场上是否存在表侧攻击表示的怪兽。
			and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 效果处理时后续判定的第二步：提示玩家是否选择把对方场上的1只攻击表示怪兽变成守备表示。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2))then  --"是否改变表示形式？"
			-- 中断当前的效果处理，使后续的改变表示形式操作不与特殊召唤同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 从对方场上选择一只表侧攻击表示的怪兽。
			local tg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 在场上高亮显示选中的被改变表示形式的怪兽。
			Duel.HintSelection(tg)
			-- 将选择的怪兽改变为表侧守备表示。
			Duel.ChangePosition(tg:GetFirst(),POS_FACEUP_DEFENSE)
		end
	end
end
-- 效果②中超量召唤的怪兽过滤条件：过滤额外卡组中的暗属性且可以进行超量召唤的超量怪兽。
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable(nil)
end
-- 效果②的发动判定与操作信息注册：检查额外卡组中是否存在可以进行超量召唤的暗属性超量怪兽，并在发动时注册特殊召唤的操作信息。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②发动判定：检查额外卡组中是否存在暗属性且可以进行超量召唤的超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置效果②处理时的操作信息：预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的执行操作：从额外卡组中选择1只暗属性超量怪兽，并使用玩家场上的怪兽作为素材对其进行超量召唤。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有符合过滤条件的暗属性超量怪兽的集合。
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要进行特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 以选定的超量怪兽为目标，在场上用符合条件的素材进行超量召唤。
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
-- 效果③的盖放回合发动条件过滤：过滤场上或墓地的「幻影骑士团」怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER)
end
-- 效果③的盖放回合发动条件判定：检查己方场上或墓地是否存在「幻影骑士团」怪兽。
function s.actcon(e)
	-- 判断己方场上或墓地是否存在「幻影骑士团」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
