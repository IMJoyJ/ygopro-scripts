--誓いのエンブレーマ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合，这个效果放置的卡或者原本卡名和那张卡相同的卡在自己场上表侧表示存在期间，自己不是「百夫长骑士」怪兽不能从额外卡组特殊召唤。
-- ●从卡组把1张「百夫长骑士」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果：注册此卡发动的两个可选效果，且该卡名的卡在1回合只能发动1张。
function s.initial_effect(c)
	-- ●从卡组把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合，这个效果放置的卡或者原本卡名和那张卡相同的卡在自己场上表侧表示存在期间，自己不是「百夫长骑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"把怪兽表侧表示放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- ●从卡组把1张「百夫长骑士」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"把魔法·陷阱卡盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索卡组中属于「百夫长骑士」且不处于禁止放置状态的怪兽卡。
function s.filter1(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果1的发动准备：检查魔法与陷阱区域是否有空位，并确认卡组中是否存在可放置的「百夫长骑士」怪兽。
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上可用的魔法与陷阱区域空格数。
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		-- 检查卡组中是否存在可放置的「百夫长骑士」怪兽，且魔法与陷阱区域有空位。
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) and ct>0
	end
end
-- 效果1的运行处理：将卡组中的1只「百夫长骑士」怪兽在魔陷区表侧表示放置，并适用后续的额外卡组特殊召唤限制。
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此时自己场上没有可用的魔法与陷阱区域空格，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1只满足条件的「百夫长骑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽表侧表示移动到自己的魔法与陷阱区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续陷阱卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		-- 这个回合，这个效果放置的卡或者原本卡名和那张卡相同的卡在自己场上表侧表示存在期间，自己不是「百夫长骑士」怪兽不能从额外卡组特殊召唤。●从卡组把1张「百夫长骑士」魔法·陷阱卡在自己场上盖放。
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetTargetRange(1,0)
		e0:SetLabel(tc:GetOriginalCodeRule())
		e0:SetCondition(s.splimitcon)
		e0:SetTarget(s.splimit)
		e0:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制玩家从额外卡组特殊召唤非「百夫长骑士」怪兽的领域效果。
		Duel.RegisterEffect(e0,tp)
	end
end
-- 过滤函数：检索场上表侧表示存在且原本卡名与放置的卡相同的卡。
function s.filter2(c,e)
	return c:IsOriginalCodeRule(e:GetLabel()) and c:IsFaceup()
end
-- 限制效果的适用条件：自己场上存在原本卡名与放置的卡相同的表侧表示卡片。
function s.splimitcon(e)
	-- 检查自己场上是否存在原本卡名与放置的卡相同的表侧表示卡片。
	return Duel.IsExistingMatchingCard(s.filter2,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,e)
end
-- 限制内容：不能从额外卡组特殊召唤「百夫长骑士」以外的怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x1a2) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：检索卡组中可盖放的「百夫长骑士」魔法·陷阱卡（若魔陷区无空位，则只能选择场地魔法卡）。
function s.setfilter(c,ct)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and (ct>0 or c:IsType(TYPE_FIELD))
end
-- 效果2的发动准备：检查卡组中是否存在可盖放的「百夫长骑士」魔法·陷阱卡。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的魔法与陷阱区域空格数。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	-- 检查卡组中是否存在至少1张满足条件的「百夫长骑士」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,ct) end
end
-- 效果2的运行处理：从卡组选择1张「百夫长骑士」魔法·陷阱卡在自己场上盖放。
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的魔法与陷阱区域空格数。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「百夫长骑士」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,ct)
	if g:GetCount()>0 then
		-- 将选中的卡片在自己场上盖放。
		Duel.SSet(tp,g:GetFirst())
	end
end
