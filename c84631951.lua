--ディノベーダー・ドクス
-- 效果：
-- 自己对「恐龙侵略者·双梁龙」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：自己场上有恐龙族怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把自己场上1只4星以下的怪兽解放才能发动。比解放的怪兽等级高2星或低2星的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
local s,id,o=GetID()
-- 初始化函数：注册同名卡1回合只能特殊召唤1次的限制，以及手卡特召和卡组特召两个起动效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- ①：自己场上有恐龙族怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只4星以下的怪兽解放才能发动。比解放的怪兽等级高2星或低2星的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的恐龙族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- ①效果的发动条件：自己场上有恐龙族怪兽2只以上存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的恐龙族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- ①效果的靶向与发动检测：检查怪兽区域空位并确认自身是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将手卡中的此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：等级在1到4之间、解放后能腾出怪兽区域空位、由自己控制（或在场上表侧表示）且卡组中存在等级比其高2或低2的恐龙族怪兽
function s.costfilter(c,e,tp)
	return c:GetLevel()>=1 and c:GetLevel()<=4
		-- 检查该怪兽解放后自己场上是否有可用的怪兽区域空位，且该怪兽由自己控制或在场上表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在等级比该怪兽高2或低2的恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤条件：卡组中等级比解放怪兽高2或低2的、可以特殊召唤的恐龙族怪兽
function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_DINOSAUR) and (c:IsLevel(lv+2) or c:IsLevel(lv-2))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的Cost处理：检查并选择自己场上1只满足条件的4星以下怪兽解放，并记录其等级
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为Cost解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) end
	-- 让玩家选择1只满足条件的怪兽作为解放对象
	local sg=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- ②效果的靶向与发动检测：设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组特殊召唤满足等级条件的恐龙族怪兽，并注册结束阶段破坏的效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只等级比解放怪兽高2或低2的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	local tc=g:GetFirst()
	-- 若成功选择，则尝试将该怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		-- 注册全局延迟效果，用于在结束阶段破坏该特殊召唤的怪兽
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏效果的触发条件：检查目标怪兽是否仍带有对应的标记，若已不在场则重置该效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的处理：破坏该特殊召唤的怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
