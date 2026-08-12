--聖蔓の交配
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1只连接怪兽解放，以那只怪兽以外的自己墓地1只植物族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c70473293.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上1只连接怪兽解放，以那只怪兽以外的自己墓地1只植物族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70473293,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,70473293)
	e2:SetCost(c70473293.cost)
	e2:SetTarget(c70473293.target)
	e2:SetOperation(c70473293.activate)
	c:RegisterEffect(e2)
end
-- 定义解放怪兽的过滤条件函数
function c70473293.costfilter(c,tp)
	-- 过滤条件：是连接怪兽，且在自己场上，并且解放后能腾出可用的怪兽区域
	return c:IsType(TYPE_LINK) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义效果发动的代价处理函数
function c70473293.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的连接怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c70473293.costfilter,1,nil,tp) end
	-- 选择自己场上1只满足条件的连接怪兽
	local rg=Duel.SelectReleaseGroup(tp,c70473293.costfilter,1,1,nil,tp)
	-- 将选择的怪兽解放
	Duel.Release(rg,REASON_COST)
	e:SetLabelObject(rg:GetFirst())
end
-- 定义特殊召唤对象的过滤条件函数
function c70473293.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的目标选择处理函数
function c70473293.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c70473293.spfilter(chkc,e,tp) and chkc~=e:GetLabelObject() end
	-- 检查自己墓地是否存在可特殊召唤的植物族怪兽
	if chk==0 then return Duel.IsExistingTarget(c70473293.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只植物族怪兽（排除作为代价解放的怪兽）作为效果的对象
	local g=Duel.SelectTarget(tp,c70473293.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetLabelObject(),e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理函数
function c70473293.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关联，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
