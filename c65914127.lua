--ペンデュラム・ペンダント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从额外卡组（表侧）把5只灵摆怪兽除外才能发动。从自己的卡组·额外卡组（表侧）把1只灵摆怪兽在自己的灵摆区域放置。
-- ②：把墓地的这张卡除外，以自己或对方的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度下降1（最少到0）。
local s,id,o=GetID()
-- 定义并注册卡片效果
function s.initial_effect(c)
	-- ①：从额外卡组（表侧）把5只灵摆怪兽除外才能发动。从自己的卡组·额外卡组（表侧）把1只灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"在灵摆区域放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己或对方的灵摆区域1张卡为对象才能发动。那张卡的灵摆刻度下降1（最少到0）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"刻度下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rstg)
	e2:SetOperation(s.rsop)
	c:RegisterEffect(e2)
end
-- 计算发动此卡时可放置的区域（限制只能在灵摆区域有空位时发动）
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	-- 检查左侧灵摆区域是否可用
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查右侧灵摆区域是否可用
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	if not b or p0 and p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 过滤条件：额外卡组表侧表示且可以作为代价除外的灵摆怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToRemoveAsCost()
end
-- 检查除外选定的怪兽后，是否仍有可放置的灵摆怪兽
function s.check(g,tp)
	-- 检查自己的卡组或额外卡组（表侧）是否存在不属于排除组的、可放置的灵摆怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,g)
end
-- 过滤条件：卡组或额外卡组表侧表示、且未被禁止放置的灵摆怪兽
function s.filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 效果①的发动代价：从额外卡组（表侧）将5只灵摆怪兽除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取额外卡组中所有满足条件的表侧表示灵摆怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>4 and g:CheckSubGroup(s.check,5,5,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.check,false,5,5,tp)
	-- 将选中的5张卡表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果①的发动准备与合法性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:IsCostChecked()
		-- 或者检查卡组·额外卡组（表侧）是否存在可放置的灵摆怪兽
		or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil))
		-- 并且自身灵摆区域至少有一个空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
end
-- 效果①的实际处理：从卡组·额外卡组（表侧）将1只灵摆怪兽放置到灵摆区域
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自身灵摆区域均无空位，则不处理
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组·额外卡组（表侧）选择1只满足条件的灵摆怪兽
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 将选中的怪兽在自己的灵摆区域表侧表示放置
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end
-- 过滤条件：当前灵摆刻度大于0的卡
function s.rfilter(c)
	return c:GetCurrentScale()>0
end
-- 效果②的对象选择与合法性检查
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	-- 检查双方灵摆区域是否存在刻度大于0的卡
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择双方灵摆区域的1张卡作为对象
	Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
end
-- 效果②的实际处理：使目标卡的灵摆刻度下降1
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那张卡的灵摆刻度下降1（最少到0）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
