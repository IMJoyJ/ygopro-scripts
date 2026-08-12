--インフェルニティ・デス・ガンマン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只恶魔族怪兽特殊召唤。
-- ②：自己·对方回合，自己手卡是0张的场合，把墓地的这张卡除外才能发动。对方从以下选1个，自己让那个适用。
-- ●自己卡组最上面的卡给双方确认，怪兽的场合，这个回合，自己受到的效果伤害由对方代受。不是的场合，自己受到4000伤害。
-- ●这个回合，自己受到的效果伤害变成0。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把1只恶魔族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，自己手卡是0张的场合，把墓地的这张卡除外才能发动。对方从以下选1个，自己让那个适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.effcon)
	-- 将墓地中的这张卡除外作为效果发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
-- 过滤条件：恶魔族且可特殊召唤的怪兽
function s.spfilter(c,e,sp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 定义效果①的Target：检查场上是否有怪兽空格，且手牌中是否存在可以特殊召唤的恶魔族怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可以特殊召唤的恶魔族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果①的Operation：从手手牌将1只恶魔族怪兽特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在手牌中选择1只符合条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示在自己场上特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②的Condition：检查自己的手牌数量是否为0
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手牌中的卡片数量是否为0
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_HAND,0,nil)==0
end
-- 定义效果②的Operation：由对方选择一个效果适用
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己卡组中是否还有卡片
	local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_DECK,0,1,nil)
	local b2=true
	local op=0
	if b1 or b2 then
		-- 让对方玩家在可用选项中选择一个适用的效果
		op=aux.SelectFromOptions(1-tp,
			{b1,aux.Stringid(id,2),1},  --"确认卡组"
			{b2,aux.Stringid(id,3),2})  --"不受效果伤害"
	end
	if op==1 then
		-- 将自己卡组最上方的1张卡给双方确认
		Duel.ConfirmDecktop(tp,1)
		-- 获取自己卡组最上方的1张卡
		local g1=Duel.GetDecktopGroup(tp,1)
		local res1=g1:GetFirst():IsType(TYPE_MONSTER)
		if res1 then
			-- ●自己卡组最上面的卡给双方确认，怪兽的场合，这个回合，自己受到的效果伤害由对方代受。不是的场合，自己受到4000伤害。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_REFLECT_DAMAGE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.val)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 为自己注册“效果伤害由对方代受”的阶段持续效果
			Duel.RegisterEffect(e1,tp)
		else
			-- 给与自己4000点的效果伤害
			Duel.Damage(tp,4000,REASON_EFFECT)
		end
	elseif op==2 then
		-- ●这个回合，自己受到的效果伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 为自己注册“受到的伤害发生改变”的阶段持续效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 为自己注册“受到的效果伤害变成0”的阶段持续效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义效果伤害转移的判定逻辑：确认受到的伤害类型是否为效果伤害
function s.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 定义效果伤害减免的判定逻辑：如果受到的是效果伤害则将其数值修改为0，否则保持原数值不变
function s.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
