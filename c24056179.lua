--カプセル・モンスター・チェス
local s,id,o=GetID()
-- 定义一个函数s.initial_effect(c)，用于注册卡牌效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建并注册一个激活类型的效果，允许这张永续魔陷/场地卡发动。此效果是永续魔陷/场地卡发动的必要条件。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- 创建并注册一个点火类型（ignition）的效果，描述为aux.Stringid(id,1)。该效果在场地区生效，可以指定对象，并且限制每回合只能发动一次。
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
-- 定义一个过滤函数s.filter(c,tp)，用于筛选墓地中的符合条件的怪兽卡片。此函数检查卡片的类型、是否被禁止、是否是唯一的、是否表侧表示以及场上是否有空的怪兽区。
function s.filter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then r=LOCATION_REASON_CONTROL end
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 检查目标玩家的怪兽区是否有空位，并确保卡片可以放置在其中。
		and c:IsFaceupEx() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- 定义一个目标选择函数s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)，用于让玩家从墓地中选择一张符合条件的怪兽卡片作为效果的目标。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	-- 检查当前是否正在进行连锁，如果是则返回true。否则，检查是否有满足s.filter的卡片在墓地存在。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家发送提示信息，要求其选择目标卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从墓地中选择一张符合条件的怪兽卡片。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置当前连锁的操作信息，表示将选定的卡片从墓地移除。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义一个效果操作函数s.mvop(e,tp,eg,ep,ev,re,r,rp)，用于将目标怪兽卡片移动到场上的怪兽区，并改变其类型为永续魔法卡。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 将目标卡片移动到场上表侧表示的怪兽区。
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 创建一个效果，将目标卡片的类型更改为永续魔法卡，并设置其属性为不可禁用、重置条件和值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 定义一个条件函数s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)，用于检查是否满足特殊召唤的条件。此函数检查当前回合玩家是否是执行效果的玩家。
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 返回当前回合玩家是否与执行效果的玩家相同。
	return Duel.GetTurnPlayer()==tp
end
-- 定义一个过滤函数s.cfilter(c,e,tp)，用于筛选场上符合条件的怪兽卡片作为特殊召唤的素材。此函数检查卡片的表侧表示、类型、是否可以送入墓地作为COST以及等级是否大于0，并确保存在满足spfilter条件的卡牌在卡组中。
function s.cfilter(c,e,tp)
	return c:IsFaceupEx() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
		-- 检查是否存在满足s.spfilter条件的卡片在卡组中。
		and c:GetOriginalLevel()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
		-- 检查玩家的怪兽区是否有空位。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 定义一个过滤函数s.spfilter(c,tc,e,tp)，用于筛选卡组中符合条件的怪兽卡片作为特殊召唤的目标。此函数比较目标卡和素材卡的等级、种族和属性，并检查目标卡是否可以特殊召唤。
function s.spfilter(c,tc,e,tp)
	local lv=c:GetOriginalLevel()-tc:GetOriginalLevel()
	return lv>0 and lv<4
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义一个COST函数s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)，用于支付特殊召唤的代价。此函数检查是否有符合条件的卡片在场上，提示玩家选择要送入墓地的卡片，并将选定的卡片送入墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足s.cfilter条件的卡片在场上。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求其选择要送入墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从场上选择一张符合条件的怪兽卡片作为COST。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选定的卡片送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 定义一个目标函数s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)，用于确定特殊召唤的目标。此函数检查是否已经支付了COST，并设置操作信息为特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置当前连锁的操作信息，表示将从卡组中特殊召唤一张怪兽卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义一个效果操作函数s.spop(e,tp,eg,ep,ev,re,r,rp)，用于执行特殊召唤的效果。此函数检查玩家的怪兽区是否有空位，获取COST对象，提示玩家选择要特殊召唤的卡片，并从卡组中特殊召唤选定的卡片。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家的怪兽区没有空位则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=e:GetLabelObject()
	-- 向玩家发送提示信息，要求其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择一张符合条件的怪兽卡片作为特殊召唤的目标。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 从卡组中特殊召唤选定的卡片。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
