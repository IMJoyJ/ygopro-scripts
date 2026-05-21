--ロリポー★ヤミーウェイ
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 这张卡同调召唤的场合，可以把自己场上1只连接1怪兽当作1星调整使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把2只「味美喵」怪兽效果无效特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，让这张卡回到额外卡组才能发动。从自己墓地把最多2只「味美喵」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片初始效果（同调召唤手续、将连接1怪兽当作1星调整使用的效果、①效果同调召唤成功时从墓地特召2只、②效果对方发动效果时回额外特召墓地最多2只）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续（1只调整或连接1怪兽 + 1只非调整且非连接怪兽）
	aux.AddSynchroMixProcedure(c,s.matfilter1,nil,nil,s.matfilter2,1,1)
	-- 这张卡同调召唤的场合，可以把自己场上1只连接1怪兽当作1星调整使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SYNCHRO_LEVEL_EX)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.syntg)
	e0:SetValue(s.synval)
	c:RegisterEffect(e0)
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把2只「味美喵」怪兽效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.gspcon)
	e1:SetTarget(s.gsptg)
	e1:SetOperation(s.gspop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，让这张卡回到额外卡组才能发动。从自己墓地把最多2只「味美喵」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤同调素材中的调整怪兽（可以是调整，或者是连接1的连接怪兽）
function s.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsType(TYPE_LINK) and c:IsLink(1)
end
-- 过滤同调素材中的非调整怪兽（必须是非调整且不能是连接怪兽）
function s.matfilter2(c,syncard)
	return c:IsNotTuner(syncard) and not c:IsType(TYPE_LINK)
end
-- 过滤可以当作同调素材使用的怪兽（必须是连接1的连接怪兽）
function s.syntg(e,c)
	return c:IsType(TYPE_LINK) and c:IsLink(1)
end
-- 设定作为同调素材时的等级（如果是这张卡进行同调召唤，则该连接1怪兽当作1星使用，否则为0星）
function s.synval(e,syncard)
	if e:GetHandler()==syncard then
		return 1
	else
		return 0
	end
end
-- 效果①的发动条件（这张卡同调召唤成功的场合）
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤墓地中可以特殊召唤的「味美喵」怪兽
function s.gspfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果①的发动准备（检查怪兽区域空位数、精灵龙限制以及墓地是否存在2只可特召的「味美喵」怪兽，并设置特殊召唤的操作信息）
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域空位数是否至少有2个
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己墓地是否存在至少2只满足特召条件的「味美喵」怪兽
		and Duel.IsExistingMatchingCard(s.gspfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从自己墓地特殊召唤2只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 效果①的效果处理（从自己墓地选择2只「味美喵」怪兽，将其效果无效并特殊召唤）
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取自己墓地中不受「王家长眠之谷」影响且满足特召条件的「味美喵」怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.gspfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 遍历选中的怪兽组
		for tc in aux.Next(sg) do
			-- 逐步将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
-- 效果②的发动条件（对方把魔法·陷阱·怪兽的效果发动时）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②的发动代价（让这张卡回到额外卡组）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将这张卡作为发动代价送回额外卡组
	Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_COST)
end
-- 过滤墓地中可以特殊召唤的「味美喵」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域空位数以及墓地是否存在可特召的「味美喵」怪兽，并设置特殊召唤的操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡离开场上后自己场上的怪兽区域空位数是否大于0，且自己墓地是否存在至少1只满足特召条件的「味美喵」怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从自己墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（从自己墓地选择最多2只「味美喵」怪兽特殊召唤）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可以特殊召唤的最大数量（最多2只且不超过当前怪兽区域空位数）
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1到ft张不受「王家长眠之谷」影响且满足特召条件的「味美喵」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
