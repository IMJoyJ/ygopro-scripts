--ドラグニティナイト－アーレウス
-- 效果：
-- 调整＋调整以外的同调怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己的魔法与陷阱区域的表侧表示的怪兽卡数量的对方场上的表侧表示卡为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那些卡的效果直到回合结束时无效。
-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只「龙骑兵团」调整特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续、启用召唤限制并注册三个效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的同调怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：以最多有自己的魔法与陷阱区域的表侧表示的怪兽卡数量的对方场上的表侧表示卡为对象才能发动（这张卡有装备卡装备的场合，这个效果在对方回合也能发动）。那些卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon1)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.discon2)
	c:RegisterEffect(e2)
	-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只「龙骑兵团」调整特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：当此卡没有装备卡时才能发动
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()==0
end
-- 效果②的发动条件：当此卡有装备卡时才能发动
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g:GetCount()>0
end
-- 过滤函数，用于判断场上表侧表示的怪兽卡
function s.cfilter(c)
	return (c:GetOriginalType()&TYPE_MONSTER)~=0 and c:IsFaceup()
end
-- 效果①的目标选择函数，根据己方场上表侧表示的魔法与陷阱区域的怪兽数量选择对方场上的卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算己方场上表侧表示的魔法与陷阱区域的怪兽数量
	local ct=Duel.GetFieldGroup(tp,LOCATION_SZONE,0):FilterCount(s.cfilter,nil)
	-- 判断目标是否满足无效化条件
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 判断是否满足发动条件：存在可作为无效化对象的卡且己方场上表侧表示的怪兽数量大于0
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的卡作为无效化对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，记录将要无效化的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果①的处理函数，使选中的卡效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的卡组
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历选中的卡组
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使目标卡的连锁无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标卡效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标卡的效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使目标陷阱怪兽无效化
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 效果②的发动条件：当此卡装备中有怪兽时才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 效果②的目标选择函数，判断是否可以特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断墓地中的龙骑兵团调整
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理函数，将此卡特殊召唤并从墓地特殊召唤一只龙骑兵团调整
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断是否有足够的召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的龙骑兵团调整
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否发动特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地中选择一只龙骑兵团调整
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的龙骑兵团调整特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
