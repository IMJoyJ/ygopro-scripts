--剣闘獣アウグストル
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功时才能发动。从手卡把1只「剑斗兽」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 奥古斯都」以外的1只「剑斗兽」怪兽特殊召唤。
function c7573135.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功时才能发动。从手卡把1只「剑斗兽」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7573135,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置发动条件为这张卡用「剑斗兽」怪兽的效果特殊召唤成功
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c7573135.hsptg)
	e1:SetOperation(c7573135.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 奥古斯都」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7573135,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c7573135.spcon)
	e2:SetCost(c7573135.spcost)
	e2:SetTarget(c7573135.sptg)
	e2:SetOperation(c7573135.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：手卡中可以表侧守备表示特殊召唤的「剑斗兽」怪兽
function c7573135.hspfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与合法性检查
function c7573135.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c7573135.hspfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（特殊召唤手卡的「剑斗兽」并注册结束阶段回到卡组的效果）
function c7573135.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c7573135.hspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(7573135,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c7573135.retcon)
		e1:SetOperation(c7573135.retop)
		-- 注册在结束阶段将该怪兽送回卡组的全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查该怪兽是否仍存在于场上且标记未失效，若失效则重置该效果
function c7573135.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(7573135)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将该怪兽送回持有者卡组的操作
function c7573135.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 检查这张卡在当前回合是否进行过战斗
function c7573135.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果②的发动代价：将自身送回持有者卡组
function c7573135.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将这张卡自身送回持有者卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：卡组中「剑斗兽 奥古斯都」以外的可以特殊召唤的「剑斗兽」怪兽
function c7573135.filter(c,e,tp)
	return c:IsSetCard(0x1019) and not c:IsCode(7573135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查
function c7573135.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（因为自身作为代价离场，所以可用区域数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在满足特殊召唤条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c7573135.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组特殊召唤1只「剑斗兽」怪兽）
function c7573135.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c7573135.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
