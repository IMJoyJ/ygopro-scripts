--インフェルニティ・ワイルドキャット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只其他的「永火」怪兽送去墓地，从手卡特殊召唤。
-- ②：自己手卡是0张的场合，把自己墓地1只「永火」怪兽除外才能发动。这张卡的等级直到回合结束时上升或者下降1星。
function c74148483.initial_effect(c)
	-- ①：这张卡可以把手卡1只其他的「永火」怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,74148483+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c74148483.spcon)
	e1:SetTarget(c74148483.sptg)
	e1:SetOperation(c74148483.spop)
	c:RegisterEffect(e1)
	-- ②：自己手卡是0张的场合，把自己墓地1只「永火」怪兽除外才能发动。这张卡的等级直到回合结束时上升或者下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74148483,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,74148484)
	e2:SetCondition(c74148483.lvcon)
	e2:SetCost(c74148483.lvcost)
	e2:SetTarget(c74148483.lvtg)
	e2:SetOperation(c74148483.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除自身以外的「永火」怪兽且可以送去墓地
function c74148483.spfilter(c)
	return c:IsSetCard(0xb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件：检查怪兽区域是否有空位，以及手卡中是否存在满足条件的「永火」怪兽
function c74148483.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 检查手卡中是否存在至少1张除自身以外的满足过滤条件的卡
	return Duel.IsExistingMatchingCard(c74148483.spfilter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的准备操作：获取手卡中满足条件的卡，并让玩家选择1张送去墓地
function c74148483.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c74148483.spfilter,tp,LOCATION_HAND,0,c)
	-- 给玩家发送“请选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作：将选中的卡送去墓地
function c74148483.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 等级变更效果的发动条件：自己手卡为0张
function c74148483.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手卡数量是否等于0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 过滤条件：墓地中的「永火」怪兽且可以作为代价除外
function c74148483.costfilter(c)
	return c:IsSetCard(0xb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 等级变更效果的发动代价：选择墓地1只「永火」怪兽除外
function c74148483.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查墓地是否存在至少1只满足除外条件的「永火」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74148483.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择墓地1只满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c74148483.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 等级变更效果的合法性检查：检查自身等级是否在1星以上
function c74148483.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(1) end
end
-- 等级变更效果的执行操作：让玩家选择上升或下降1星，并适用该等级变化效果直到回合结束
function c74148483.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local opt=0
		if c:IsLevel(1) then
			-- 若自身等级为1星，则只能选择“等级上升”选项
			opt=Duel.SelectOption(tp,aux.Stringid(74148483,1))  --"等级上升"
		else
			-- 若自身等级大于1星，则让玩家选择“等级上升”或“等级下降”
			opt=Duel.SelectOption(tp,aux.Stringid(74148483,1),aux.Stringid(74148483,2))  --"等级上升/等级下降"
		end
		-- 这张卡的等级直到回合结束时上升或者下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if opt==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
