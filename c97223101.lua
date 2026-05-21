--BBS
-- 效果：
-- ①：每次「快回揭示板」以外的卡的效果发动才能发动。给这张卡放置1个访问指示物（最多10个）。
-- ②：自己场上的怪兽的攻击力上升这张卡的访问指示物数量×100。
-- ③：这张卡有访问指示物被放置，那些访问指示物数量变成10的场合才能发动。这张卡回到手卡，把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 初始化函数，注册卡片的基本信息、允许放置指示物、发动时的空效果、放置指示物的诱发效果、提升攻击力的永续效果，以及指示物满10个时回手牌并盖放永续陷阱的诱发效果。
function s.initial_effect(c)
	c:EnableCounterPermit(0x6c)
	c:SetCounterLimit(0x6c,10)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「快回揭示板」以外的卡的效果发动才能发动。给这张卡放置1个访问指示物（最多10个）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽的攻击力上升这张卡的访问指示物数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	-- ③：这张卡有访问指示物被放置，那些访问指示物数量变成10的场合才能发动。这张卡回到手卡，把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回到手卡并盖放魔陷"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 检查发动效果的卡片是否不是本卡，作为放置指示物效果的发动条件。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(id)
end
-- 检查本卡是否可以放置访问指示物，作为放置指示物效果的发动靶向检测。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x6c,1) end
end
-- 放置指示物效果的处理：给本卡放置1个访问指示物，并在指示物数量达到10时触发自定义事件。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x6c,1)
		if c:GetCounter(0x6c)==10 then
			-- 触发自定义事件，用于在指示物数量变为10时诱发后续效果。
			Duel.RaiseEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end
-- 计算攻击力上升值，返回本卡的访问指示物数量乘以100。
function s.val(e,c)
	return e:GetHandler():GetCounter(0x6c)*100
end
-- 过滤卡组中满足条件的卡：必须是永续陷阱卡，且具有将其作为怪兽特殊召唤的效果（通过检查其原始等级、种族、属性、攻击力或守备力是否大于0来判定）。
function s.filter(c,ignore)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable(ignore)
		and (c:GetOriginalLevel()>0
		or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
		or bit.band(c:GetOriginalAttribute(),0x7f)~=0
		or c:GetBaseAttack()>0
		or c:GetBaseDefense()>0)
end
-- 效果③的发动检测：确认触发事件包含本卡、指示物数量为10、本卡可以回到手卡、自己魔陷区有空位，且卡组中存在符合条件的永续陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsContains(c) and c:GetCounter(0x6c)==10 and c:IsAbleToHand()
		-- 检查在将本卡送回手卡后，自己的魔法与陷阱区域是否有可用于盖放卡片的空位。
		and Duel.GetSZoneCount(tp,c)>0
		-- 检查卡组中是否存在至少1张满足条件的永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,true) end
	-- 设置连锁处理的操作信息，表明此效果包含将本卡回到手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果③的效果处理：将本卡回到手卡，若成功则从卡组选择1张满足条件的永续陷阱卡在自己场上盖放，并赋予其在盖放的回合也能发动的效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查本卡是否仍受效果影响，并将其通过效果送回手卡，确认其已成功到达手卡。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) then
		-- 检查自己的魔法与陷阱区域是否有空位，若无空位则结束效果处理。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 向玩家发送提示信息，要求选择要盖放的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组中选择1张满足条件的永续陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		local tc=g:GetFirst()
		-- 若成功选择卡片，则将其在自己场上盖放。
		if tc and Duel.SSet(tp,tc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))  --"适用「快回揭示板」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
