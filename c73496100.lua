--ガガガイリュージョン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「我我我」怪兽存在的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把那只怪兽的等级·阶级变成和自己场上1只「我我我」怪兽的等级·阶级的数值相同。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。进行1只「我我我」怪兽的召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（特殊召唤并可改变等级/阶级）和②效果（墓地除外追加召唤）
function s.initial_effect(c)
	-- ①：自己场上有「我我我」怪兽存在的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把那只怪兽的等级·阶级变成和自己场上1只「我我我」怪兽的等级·阶级的数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。进行1只「我我我」怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"追加召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置②效果的Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「我我我」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
-- ①效果的发动条件：自己场上有「我我我」怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「我我我」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：可以被特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择与发动准备函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只可以特殊召唤的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只可以特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：自己场上表侧表示的「我我我」怪兽，且其等级或阶级与特殊召唤的怪兽不同
function s.cfilter2(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x54)
		and (c:IsLevelAbove(1) or c:IsRankAbove(1))
		and not (c:IsLevel(lv) or c:IsRank(lv))
end
-- ①效果的实际处理函数：特殊召唤目标怪兽，并可选择改变其等级或阶级
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与连锁相关，且不受王家之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将该怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local lv=0
		if tc:IsLevelAbove(1) then lv=tc:GetLevel() end
		if tc:IsRankAbove(1) then lv=tc:GetRank() end
		-- 检查特殊召唤的怪兽是否有等级/阶级，且自己场上是否存在其他等级/阶级不同的「我我我」怪兽
		if lv~=0 and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,tc,lv)
			-- 询问玩家是否选择改变该怪兽的等级或阶级
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变等级阶级？"
			-- 中断当前效果处理，使后续的等级/阶级改变处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择表侧表示的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 选择自己场上1只用于参照等级/阶级的「我我我」怪兽
			local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,tc,lv)
			local tc2=g:GetFirst()
			-- 手动显示被选择怪兽的动画效果
			Duel.HintSelection(g)
			local lv2=0
			if tc2:IsLevelAbove(1) then lv2=tc2:GetLevel() end
			if tc2:IsRankAbove(1) then lv2=tc2:GetRank() end
			-- 可以把那只怪兽的等级·阶级变成和自己场上1只「我我我」怪兽的等级·阶级的数值相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			if tc:IsLevelAbove(1) then
				e1:SetCode(EFFECT_CHANGE_LEVEL)
			else
				e1:SetCode(EFFECT_CHANGE_RANK)
			end
			e1:SetValue(lv2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 过滤条件：手卡或场上可以进行通常召唤的「我我我」怪兽
function s.sumfilter(c)
	return c:IsSetCard(0x54) and c:IsSummonable(true,nil)
end
-- ②效果的目标选择与发动准备函数
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可以进行通常召唤的「我我我」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理中的操作信息：进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的实际处理函数：进行1只「我我我」怪兽的召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择手卡或场上1只可以召唤的「我我我」怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 忽略每回合的通常召唤次数限制，对选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
