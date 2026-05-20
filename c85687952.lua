--原始生命態ティア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把等级合计直到11以上的自己场上的怪兽解放才能发动。这张卡从手卡特殊召唤。那之后，自己场上没有其他怪兽存在的场合，可以把场上1只攻击力最高的怪兽破坏。
-- ②：只要这张卡在怪兽区域存在，那个期间双方1回合只能有最多4次把怪兽召唤·特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册召唤/特殊召唤成功时的计数效果，以及手卡特殊召唤并破坏怪兽的即时效果
function s.initial_effect(c)
	-- ②：只要这张卡在怪兽区域存在，那个期间双方1回合只能有最多4次把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.checkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ①：自己·对方的主要阶段，把等级合计直到11以上的自己场上的怪兽解放才能发动。这张卡从手卡特殊召唤。那之后，自己场上没有其他怪兽存在的场合，可以把场上1只攻击力最高的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 召唤·特殊召唤成功时的处理：记录双方玩家本回合的召唤·特召次数，并根据已召唤·特召次数对双方玩家适用剩余召唤·特召次数限制或禁止召唤·特召的效果
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then return end
	for p=0,1 do
		if eg:IsExists(Card.IsSummonPlayer,1,nil,p) then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,p)
		end
	end
	local tptable=table.pack(c:GetFlagEffectLabel(id))
	local tpvalue={0,0}
	for i,v in ipairs(tptable) do
		if v==0 then
			tpvalue[1]=tpvalue[1]+1
		elseif v==1 then
			tpvalue[2]=tpvalue[2]+1
		end
	end
	for p=0,1 do
		if tpvalue[p+1]<4 then
			-- 双方1回合只能有最多4次把怪兽召唤·特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,1)
			e1:SetValue(4-tpvalue[p+1])
			e1:SetLabel(p)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		elseif tpvalue[p+1]==4 then
			-- 双方1回合只能有最多4次把怪兽召唤·特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,1)
			e2:SetLabel(p)
			e2:SetTarget(s.splimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_SUMMON)
			c:RegisterEffect(e3)
		end
	end
end
-- 限制效果的目标过滤：仅适用于对应被限制的玩家
function s.splimit(e,c,sp,st)
	return sp==e:GetLabel()
end
-- 解放怪兽的合法性检测：等级合计在11以上，且解放后有足够的怪兽区域用于特殊召唤
function s.relgoal(sg,tp)
	-- 设置已选择的卡片组，用于后续的等级合计计算
	Duel.SetSelectedCard(sg)
	-- 检查选中的怪兽等级合计是否在11以上，且解放这些怪兽后主怪兽区是否有空位
	return sg:CheckWithSumGreater(Card.GetLevel,11) and aux.mzctcheckrel(sg,tp)
end
-- ①效果发动条件：自己·对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 解放怪兽的过滤条件：场上有等级且等级在1以上的怪兽
function s.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1)
end
-- ①效果发动代价：解放等级合计直到11以上的自己场上的怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可解放的、等级在1以上的怪兽
	local mg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil)
	if chk==0 then return mg:CheckSubGroup(s.relgoal,1,12,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=mg:SelectSubGroup(tp,s.relgoal,false,1,12,tp)
	-- 使用代替解放的效果（如暗影敌托邦等）
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的怪兽解放
	Duel.Release(sg,REASON_COST)
end
-- ①效果发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（特殊召唤自身1只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：特殊召唤自身，若自己场上没有其他怪兽，则可以破坏场上1只攻击力最高的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 特殊召唤自身成功，且自己场上没有其他怪兽存在
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 且场上存在至少1只表侧表示的怪兽
		and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>0
		-- 询问玩家是否发动破坏效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏怪兽？"
		-- 获取场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			local tg=g:GetMaxGroup(Card.GetAttack)
			if tg:GetCount()>1 then
				-- 提示玩家选择要破坏的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local sg=tg:Select(tp,1,1,nil)
				-- 对选中的怪兽进行闪烁提示
				Duel.HintSelection(sg)
				-- 破坏选中的攻击力最高的怪兽
				Duel.Destroy(sg,REASON_EFFECT)
			else
				-- 破坏场上唯一攻击力最高的怪兽
				Duel.Destroy(tg,REASON_EFFECT)
			end
		end
	end
end
