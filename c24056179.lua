--カプセル・モンスター・チェス
local s,id,o=GetID()
-- 定义卡片初始效果函数，用于注册各种效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建并注册一个激活类型的效果，允许这张永续魔陷/场地卡被发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- 创建并注册一个起动效果，描述为aux.Stringid(id,1)，类型为点火效果，作用范围为场地区，可以指定对象，限制每回合一次，目标是s.mvtg函数，操作是s.mvop函数。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数s.filter，用于筛选墓地中的符合条件的怪兽卡片。
function s.filter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then r=LOCATION_REASON_CONTROL end
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 检查怪兽是否表侧表示且场上存在空的怪兽区。
		and c:IsFaceupEx() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- 定义目标选择函数s.mvtg，用于让玩家从墓地中选择一只符合条件的怪兽作为效果的目标。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	-- 如果正在进行连锁处理，则返回true，否则检查是否有满足s.filter的卡片在墓地中。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从墓地中选择一张符合条件的卡片。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息，表示将选中的卡片从墓地移除。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义效果操作函数s.mvop，用于执行将目标怪兽移到怪兽区的效果。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 如果目标卡片参与了连锁且不受效果影响，则将其特殊召唤到怪兽区表侧表示。
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 将目标怪兽变成永续魔法卡，使其类型发生改变。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 定义条件函数s.spcon，用于判断是否满足特殊召唤的条件（当前回合玩家）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 返回当前回合是否为tp的回合。
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数s.cfilter，用于筛选场上符合条件的怪兽卡片作为特殊召唤的素材。
function s.cfilter(c,e,tp)
	return c:IsFaceupEx() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
		-- 检查是否有满足s.spfilter的卡片在卡组中。
		and c:GetOriginalLevel()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
		-- 检查玩家场上的怪兽区是否还有空位。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 定义过滤函数s.spfilter，用于筛选符合等级、种族和属性要求的卡片作为特殊召唤的目标。
function s.spfilter(c,tc,e,tp)
	local lv=c:GetOriginalLevel()-tc:GetOriginalLevel()
	return lv>0 and lv<4
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的COST函数s.spcost，用于支付特殊召唤所需的费用（将一张怪兽送入墓地）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足s.cfilter条件的卡在场上。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从场上选择一张符合条件的卡片作为COST。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选中的卡片送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 定义目标选择函数s.sptg，用于确定特殊召唤的目标卡片。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息，表示从卡组中特殊召唤一张怪兽卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的操作函数s.spop，用于执行特殊召唤的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家的怪兽区已满，则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=e:GetLabelObject()
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择一张符合条件的卡片作为特殊召唤的目标。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片特殊召唤到场上表侧表示。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
