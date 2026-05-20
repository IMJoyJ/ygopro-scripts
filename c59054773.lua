--イグニスターAiランド
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能把这个效果发动。从手卡把1只4星以下的「@火灵天星」怪兽特殊召唤。这个回合自己不能把原本属性相同的怪兽用「火灵天星“艾”心乐园岛」的效果特殊召唤，不是电子界族怪兽不能特殊召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把1只「@火灵天星」怪兽除外才能发动。这张卡在自己场上盖放。
function c59054773.initial_effect(c)
	-- 将自身卡名加入辅助代码列表（用于卡名相关效果的检索或判定）
	aux.AddCodeList(c,59054773)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合才能把这个效果发动。从手卡把1只4星以下的「@火灵天星」怪兽特殊召唤。这个回合自己不能把原本属性相同的怪兽用「火灵天星“艾”心乐园岛」的效果特殊召唤，不是电子界族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59054773,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c59054773.spcon)
	e2:SetTarget(c59054773.sptg)
	e2:SetOperation(c59054773.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，从自己墓地把1只「@火灵天星」怪兽除外才能发动。这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59054773,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,59054773)
	e3:SetCost(c59054773.setcost)
	e3:SetTarget(c59054773.settg)
	e3:SetOperation(c59054773.setop)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于判断怪兽是否在主要怪兽区域（格子编号0-4）
function c59054773.cfilter(c)
	return c:GetSequence()<5
end
-- 效果①的发动条件：自己的主要怪兽区域没有怪兽存在
function c59054773.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区域是否不存在任何怪兽
	return not Duel.IsExistingMatchingCard(c59054773.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：手牌中等级4以下且属于「@火灵天星」系列的可特殊召唤怪兽
function c59054773.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查主要怪兽区域是否有空位，以及手牌中是否存在可特殊召唤的怪兽
function c59054773.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 以及手牌中是否存在满足条件的「@火灵天星」怪兽
		and Duel.IsExistingMatchingCard(c59054773.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果①的效果处理：从手牌特殊召唤1只「@火灵天星」怪兽，并适用后续的特殊召唤限制
function c59054773.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的主要怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手牌选择1只满足条件的「@火灵天星」怪兽
		local g=Duel.SelectMatchingCard(tp,c59054773.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 如果成功将选中的怪兽特殊召唤
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个回合自己不能把原本属性相同的怪兽用「火灵天星“艾”心乐园岛」的效果特殊召唤
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetLabel(g:GetFirst():GetOriginalAttribute())
			e1:SetTarget(c59054773.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册该回合内不能用此卡效果特殊召唤相同原本属性怪兽的玩家限制效果
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- 不是电子界族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c59054773.splimit2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内非电子界族怪兽不能特殊召唤的玩家限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件函数：阻止使用「火灵天星“艾”心乐园岛」的效果特殊召唤与已召唤怪兽原本属性相同的怪兽
function c59054773.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se and se:GetHandler():IsCode(59054773) and c:GetOriginalAttribute()==e:GetLabel()
end
-- 限制条件函数：阻止特殊召唤非电子界族的怪兽
function c59054773.splimit2(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 过滤函数：墓地中用于作为发动成本除外的「@火灵天星」怪兽
function c59054773.costfilter(c)
	return c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本：从自己墓地把1只「@火灵天星」怪兽除外
function c59054773.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可作为发动成本除外的「@火灵天星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59054773.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从墓地选择1只「@火灵天星」怪兽
	local g=Duel.SelectMatchingCard(tp,c59054773.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备：检查此卡是否可以盖放，并设置操作信息
function c59054773.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置效果处理信息：此卡（墓地中）离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡在自己场上盖放
function c59054773.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
