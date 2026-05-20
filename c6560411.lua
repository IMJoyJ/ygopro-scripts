--黒薔薇の破滅竜
-- 效果：
-- 植物族调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：每次对方把怪兽的效果发动，给与对方600伤害，对方场上的全部怪兽的攻击力下降600。
-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「黑蔷薇龙」当作同调召唤作特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只4星以下的植物族调整特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 注册该卡记载了「黑蔷薇龙」（卡号73580471）的事实
	aux.AddCodeList(c,73580471)
	c:EnableReviveLimit()
	-- 设置同调召唤条件：植物族调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),aux.NonTuner(nil),1)
	-- ①：每次对方把怪兽的效果发动，给与对方600伤害，对方场上的全部怪兽的攻击力下降600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	-- ①：每次对方把怪兽的效果发动，给与对方600伤害，对方场上的全部怪兽的攻击力下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「黑蔷薇龙」当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只4星以下的植物族调整特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	-- 设置发动代价为把墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 对方发动怪兽效果时，为自身注册一个在当前连锁内有效的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_MONSTER) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- 检查是否满足给予伤害和降低攻击力的条件（对方发动了怪兽效果，且自身有对应的标记）
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查发动效果的玩家是对方、对方LP大于0、自身带有标记且发动的效果是怪兽效果
	return ep~=tp and Duel.GetLP(1-tp)>0 and c:GetFlagEffect(id)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- 给予对方伤害，并使对方场上所有表侧表示怪兽的攻击力下降
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了该卡的效果
	Duel.Hint(HINT_CARD,0,id)
	-- 尝试给予对方600点效果伤害，若成功造成伤害则继续处理
	if Duel.Damage(1-tp,600,REASON_EFFECT)>0 then
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		-- 遍历对方场上的所有表侧表示怪兽
		for tc in aux.Next(g) do
			-- 对方场上的全部怪兽的攻击力下降600。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-600)
			tc:RegisterEffect(e1)
		end
	end
end
-- 检查当前是否为自己或对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 效果②的发动代价处理函数（解放自身）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤额外卡组中可以当作同调召唤特殊召唤的「黑蔷薇龙」
function s.spfilter(c,e,tp,sc)
	return c:IsCode(73580471) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查在解放自身后，额外卡组怪兽特殊召唤所需的可用额外怪兽区域是否充足
		and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 效果②的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为同调素材的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在可以特殊召唤的「黑蔷薇龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁信息，表明该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的实际处理：从额外卡组将1只「黑蔷薇龙」当作同调召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查必须作为同调素材的限制，若不满足则不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「黑蔷薇龙」
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 若成功将选中的怪兽以同调召唤的方式特殊召唤
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
-- 过滤墓地中4星以下的植物族调整
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与合法性检查
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的4星以下植物族调整
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁信息，表明该效果包含从墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的实际处理：从自己墓地选择1只4星以下的植物族调整特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只满足条件且不受「王家长眠之谷」影响的植物族调整
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
