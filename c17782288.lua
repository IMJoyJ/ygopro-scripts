--Angelechy Problem
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动和特殊召唤效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 起动效果，支付1张魔法陷阱卡的弃置费用，可以特殊召唤2星的圣骑士族怪兽到场上，并可将1张圣骑士族怪兽放置到场地区域
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 诱发即时效果，当己方场上的圣骑士族怪兽被破坏时，可以将该区域的圣骑士族魔法陷阱卡送回卡组，若成功则可以选择特殊召唤该卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.tecon)
	e3:SetTarget(s.tetg)
	e3:SetOperation(s.teop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手牌中是否存在魔法陷阱卡且可被弃置
function s.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 特殊召唤效果的费用处理，检查是否有满足条件的手牌并弃置1张
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行弃置手牌操作
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤函数，用于判断额外卡组中是否存在符合条件的圣骑士族怪兽
function s.setfilter(c,tp)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤函数，用于判断额外卡组中是否存在符合条件的2星圣骑士族怪兽且可特殊召唤
function s.spfilter(c,e,tp,sp2)
	return c:IsLevel(2) and c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的额外卡组召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 检查是否满足放置到场地区域的条件
		and (not sp2 or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_EXTRA,0,1,c,tp))
end
-- 特殊召唤效果的目标确认，检查是否有符合条件的怪兽可以特殊召唤并确保场上存在空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的怪兽可以特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true)
		-- 确保场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置操作信息，表示将要特殊召唤1张额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的处理函数，根据条件选择并特殊召唤怪兽，若满足条件则可放置到场地区域并改变其类型为魔法陷阱
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有符合条件的怪兽可以特殊召唤
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择符合条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,true)
		-- 执行特殊召唤操作并判断是否成功
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 检查场上是否还有空位
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
			-- 提示玩家选择要放置到场地区的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 选择符合条件的怪兽放置到场地区域
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			local tc=sg:GetFirst()
			if tc then
				-- 将选中的卡移动到场地区域
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				-- 将选中的卡类型改变为魔法陷阱卡
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
		end
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择符合条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,false)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数，用于判断被破坏的怪兽是否满足条件（为圣骑士族、在场上以表侧表示被破坏且因战斗或效果被破坏）
function s.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and c:IsPreviousSetCard(0x1e2)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 诱发效果的触发条件，当己方场上的圣骑士族怪兽被破坏时触发
function s.tecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数，用于判断场地区域中是否存在符合条件的圣骑士族魔法陷阱卡
function s.tefilter(c,tp)
	return c:IsSetCard(0x1e2) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and c:IsAbleToExtra() and c:IsFaceup() and c:GetOwner()==tp
end
-- 诱发效果的目标确认，检查是否有符合条件的卡可以送回卡组
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的卡可以送回卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 获取符合条件的卡组
	local g=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_SZONE,0,nil,tp)
	-- 设置操作信息，表示将要将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 诱发效果的处理函数，选择并送回卡组，若成功则可特殊召唤该卡
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择符合条件的卡送回卡组
	local sg=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	if sg:GetCount()>0 then
		-- 显示选中的卡被选为对象
		Duel.HintSelection(sg)
		-- 执行送回卡组操作
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			local tc=sg:GetFirst()
			if tc:IsLocation(LOCATION_EXTRA)
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 检查是否有足够的额外卡组召唤位置
				and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
				-- 询问玩家是否特殊召唤该卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 执行特殊召唤操作
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
