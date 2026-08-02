--BBS
-- 效果：
-- ①：每次「快回揭示板」以外的卡的效果发动才能发动。给这张卡放置1个访问指示物（最多10个）。
-- ②：自己场上的怪兽的攻击力上升这张卡的访问指示物数量×100。
-- ③：这张卡有访问指示物被放置，那些访问指示物数量变成10的场合才能发动。这张卡回到手卡，把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 注册卡片的基本属性和所有效果。
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
s.mentioned_counter={
	[0x6c]=true,
}
-- 放置指示物效果的发动条件判断：确认发动的效果不是「快回揭示板」本身的效果。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(id)
end
-- 放置指示物效果的发动前检查：确认这张卡是否还可以放置访问指示物。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x6c,1) end
end
-- 给这张卡放置指示物的具体处理，并在数量达到10时触发后续的自定义事件。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x6c,1)
		if c:GetCounter(0x6c)==10 then
			-- 触发卡片的自定义事件，用于满足效果③的发动条件。
			Duel.RaiseEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end
-- 计算自己场上怪兽攻击力上升的数值，即访问指示物数量乘以100。
function s.val(e,c)
	return e:GetHandler():GetCounter(0x6c)*100
end
-- 用于筛选可以盖放的，持有把自身作为怪兽特殊召唤效果的永续陷阱卡的过滤函数。
function s.filter(c,ignore)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable(ignore)
		and (c:GetOriginalLevel()>0
		or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
		or bit.band(c:GetOriginalAttribute(),0x7f)~=0
		or c:GetBaseAttack()>0
		or c:GetBaseDefense()>0)
end
-- 回收并盖放卡片效果的发动前检查与操作信息设置。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsContains(c) and c:GetCounter(0x6c)==10 and c:IsAbleToHand()
		-- 检查这张卡回到手卡后，自己场上是否有可用的魔陷区来盖放卡片。
		and Duel.GetSZoneCount(tp,c)>0
		-- 检查卡组中是否存在满足条件的永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,true) end
	-- 告知系统该效果包含将这张卡回到手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 回收并盖放卡片效果的具体处理。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡回到手卡，并确认是否成功回到手卡中。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) then
		-- 确认自己场上是否有可用的魔陷区用于盖放卡片。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要从卡组盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组中选择1张满足条件的永续陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		local tc=g:GetFirst()
		-- 将选中的卡盖放在场上，并确认是否成功盖放。
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
