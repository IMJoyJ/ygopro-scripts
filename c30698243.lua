--スカーレッド・ハイパーノヴァ・ドラゴン
-- 效果：
-- 调整4只＋调整以外的同调怪兽1只以上
-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
-- ②：场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
-- ③：自己·对方回合1次，可以发动。这张卡以及对方的场上·墓地的卡全部除外。那之后，可以从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果和同调程序
function s.initial_effect(c)
	-- 记录该卡拥有「真红莲新星龙」的卡名
	aux.AddCodeList(c,97489701)
	-- 添加混合同调程序，要求4只调整+1只调整以外的同调怪兽
	aux.AddSynchroMixProcedure(c,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),nil,nil,s.mfilter,4,99,s.syncheck)
	c:EnableReviveLimit()
	-- 效果①：这张卡的召唤条件必须是使用指定卡为同调素材的同调召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	-- 效果①：这张卡的攻击力上升自己墓地的调整数量×500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 效果②：对方不能把场上的这张卡作为效果的对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果②的过滤函数，判断是否为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 效果②：场上的这张卡不会被对方的效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	-- 设置效果②的过滤函数，判断是否被对方效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- 效果③：自己·对方回合1次，可以发动。这张卡以及对方的场上·墓地的卡全部除外。那之后，可以从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))  --"除外"
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetTarget(s.retg)
	e5:SetOperation(s.reop)
	c:RegisterEffect(e5)
	-- 效果③：该卡的特殊召唤条件为必须使用指定卡为同调素材
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(21142671)
	c:RegisterEffect(e6)
end
s.material_type=TYPE_SYNCHRO
-- 同调召唤条件判断函数，确保召唤方式为同调召唤且无其他效果影响
function s.synlimit(e,se,sp,st)
	return st&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO and not se
end
-- 同调素材过滤函数，筛选满足条件的同调怪兽
function s.mfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER) or not c:IsSynchroType(TYPE_TUNER) and c:IsSynchroType(TYPE_SYNCHRO)
end
-- 同调检查函数，判断是否满足4只调整+1只非调整的同调条件
function s.mgcheck(c,mg,syncard)
	local rg=mg-c
	if c:IsNotTuner(syncard) and c:IsSynchroType(TYPE_SYNCHRO) then
		return rg:FilterCount(Card.IsTuner,nil,syncard)==4
	else
		return false
	end
end
-- 同调检查函数，用于判断是否满足混合同调条件
function s.syncheck(g,syncard)
	return g:IsExists(s.mgcheck,1,nil,g,syncard)
end
-- 攻击力计算函数，根据墓地调整数量计算攻击力
function s.atkval(e,c)
	-- 获取墓地调整数量并乘以500作为攻击力
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_TUNER)*500
end
-- 效果③的发动时处理函数，设置除外目标
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	-- 获取场上及墓地可除外的卡
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	sg:AddCard(c)
	-- 设置操作信息，提示将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)
end
-- 特殊召唤过滤函数，筛选「真红莲新星龙」并满足特殊召唤条件
function s.spfilter(c,e,tp)
	return c:IsCode(97489701) and c:IsType(TYPE_SYNCHRO)
		-- 判断是否满足特殊召唤条件，包括位置和召唤限制
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 除外卡过滤函数，判断卡是否属于当前玩家
function s.rmfilter(c,tp)
	return c:GetPreviousControler()==tp
end
-- 效果③的发动处理函数，执行除外并特殊召唤
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前玩家墓地的卡
	local ckg=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 检查是否因王家长眠之谷而无效当前处理
	if aux.NecroValleyNegateCheck(ckg) then return end
	-- 获取场上及墓地可除外的卡
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if c:IsRelateToChain() and c:IsAbleToRemove() then sg:AddCard(c) end
	-- 执行除外操作，将卡除外
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取实际被除外的卡组
		local og=Duel.GetOperatedGroup()
		if og:GetCount()>0
			-- 检查是否满足必须成为同调素材的条件
			and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			-- 检查额外卡组是否存在符合条件的「真红莲新星龙」
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
			-- 询问玩家是否发动特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，避免错时点
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择符合条件的「真红莲新星龙」
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
			if tc then
				tc:SetMaterial(nil)
				-- 执行特殊召唤操作，将卡特殊召唤到场上
				if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
end
