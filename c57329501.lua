--海晶乙女の潜逅
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
-- ●以连接怪兽以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ●自己的场地区域有「海晶少女的斗海」存在的场合才能发动。从卡组把1只「海晶少女」怪兽特殊召唤。
function c57329501.initial_effect(c)
	-- 记录这张卡的效果中记有「海晶少女的斗海」的卡名
	aux.AddCodeList(c,91027843)
	-- ①：可以从以下效果选择1个发动。这张卡的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。●以连接怪兽以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽特殊召唤。●自己的场地区域有「海晶少女的斗海」存在的场合才能发动。从卡组把1只「海晶少女」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57329501+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c57329501.target)
	e1:SetOperation(c57329501.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：连接怪兽以外的、可以特殊召唤的「海晶少女」怪兽
function c57329501.spfilter(c,e,tp)
	return c:IsSetCard(0x12b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsType(TYPE_LINK)
end
-- 效果①的发动准备与目标选择（检测是否满足发动条件、选择分支效果、进行取对象或声明操作信息）
function c57329501.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57329501.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在可以特殊召唤的连接怪兽以外的「海晶少女」怪兽（分支1的条件）
	local b1=Duel.IsExistingTarget(c57329501.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查自己卡组是否存在可以特殊召唤的连接怪兽以外的「海晶少女」怪兽（分支2的条件之一）
	local b2=Duel.IsExistingMatchingCard(c57329501.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查自己的场地区域是否存在「海晶少女的斗海」（分支2的条件之二）
		and Duel.IsEnvironment(91027843,tp,LOCATION_FZONE)
	-- 检查是否至少有一个分支满足发动条件，且自己场上有可用的怪兽区域
	if chk==0 then return (b1 or b2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local op=0
	if b1 and b2 then
		-- 两个分支都满足时，让玩家选择发动其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(57329501,0),aux.Stringid(57329501,1))  --"从墓地特殊召唤/从卡组特殊召唤"
	elseif b1 then
		-- 仅满足分支1时，强制选择从墓地特殊召唤的效果
		op=Duel.SelectOption(tp,aux.Stringid(57329501,0))  --"从墓地特殊召唤"
	else
		-- 仅满足分支2时，强制选择从卡组特殊召唤的效果
		op=Duel.SelectOption(tp,aux.Stringid(57329501,1))+1  --"从卡组特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己墓地1只满足条件的「海晶少女」怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c57329501.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置特殊召唤的操作信息（对象为选择的墓地怪兽）
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetProperty(0)
		-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果①的执行处理（根据选择的分支进行特殊召唤，并适用只能特殊召唤水属性怪兽的限制）
function c57329501.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 获取作为效果对象的墓地怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 检查自己场上是否有可用的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组选择1只满足条件的「海晶少女」怪兽
			local g=Duel.SelectMatchingCard(tp,c57329501.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的卡组怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c57329501.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该限制效果，使其在当前回合对玩家生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能特殊召唤水属性以外的怪兽
function c57329501.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
