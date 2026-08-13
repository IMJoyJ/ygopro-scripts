--クロノダイバー・レギュレーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有这张卡以外的怪兽存在的场合，把这张卡解放才能发动。从卡组把「时间潜行者规范针表犬」以外的2只「时间潜行者」怪兽守备表示特殊召唤（同名卡最多1张）。
-- ②：这张卡在墓地存在的状态，自己的超量怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19891131.initial_effect(c)
	-- ①：自己场上没有这张卡以外的怪兽存在的场合，把这张卡解放才能发动。从卡组把「时间潜行者规范针表犬」以外的2只「时间潜行者」怪兽守备表示特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19891131,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19891131)
	e1:SetCondition(c19891131.spcon)
	e1:SetCost(c19891131.spcost)
	e1:SetTarget(c19891131.sptg)
	e1:SetOperation(c19891131.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的超量怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(19891131,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19891132)
	e2:SetCondition(c19891131.spcon2)
	e2:SetTarget(c19891131.sptg2)
	e2:SetOperation(c19891131.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己场上存在的怪兽只有这张卡（即自己场上怪兽数量为1）。
function c19891131.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上怪兽数量是否等于1，用于判定“自己场上没有这张卡以外的怪兽存在”。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 效果①的发动代价：先确认这张卡可以被解放，然后将其解放作为发动代价。
function c19891131.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放代价（REASON_COST+REASON_RELEASE）将这张卡解放。
	Duel.Release(e:GetHandler(),REASON_COST+REASON_RELEASE)
end
-- 特殊召唤的筛选条件：卡名属于「时间潜行者」字段、不是「时间潜行者规范针表犬」、可以表侧守备表示特殊召唤。
function c19891131.spfilter(c,e,tp)
	return c:IsSetCard(0x126) and not c:IsCode(19891131) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①发动时点合法性检查：自己场上至少2个可用怪兽区、没有受到「青眼精灵龙」的“不能把2只以上的怪兽同时特殊召唤”影响、卡组中存在至少2张卡名不同的满足条件的「时间潜行者」怪兽。
function c19891131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 从卡组获取所有满足特殊召唤条件的「时间潜行者」怪兽集合，用于后续个数判断。
		local g=Duel.GetMatchingGroup(c19891131.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息：本次效果为特殊召唤，预计从卡组特殊召唤2只怪兽给玩家tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果①处理：再次确认没有「青眼精灵龙」限制且有2个可用怪兽区，然后从卡组选出2张卡名不同的「时间潜行者」怪兽表侧守备表示特殊召唤。
function c19891131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再次确认自己场上至少有2个可用怪兽区，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从卡组获取满足条件的「时间潜行者」怪兽集合，供玩家选择。
	local g=Duel.GetMatchingGroup(c19891131.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候补中选出2张卡名互不相同的「时间潜行者」怪兽（同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选出的2只怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 辅助过滤函数：判断被战斗破坏的怪兽是否是自己控制的超量怪兽。
function c19891131.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsPreviousControler(tp)
end
-- 效果②的发动条件：本次被战斗破坏的怪兽中存在自己控制的超量怪兽。
function c19891131.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19891131.cfilter,1,nil,tp)
end
-- 效果②发动合法性检查：这张卡在墓地且可以被特殊召唤，同时自己场上有可用怪兽区。
function c19891131.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，以确保这张卡能从墓地特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次处理要将墓地中的这张卡特殊召唤（对象确定，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②处理：若这张卡仍与效果关联则将其表侧攻击表示特殊召唤，并附加离场时除外的效果。
function c19891131.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且特殊召唤成功，成功后继续为它附加离场除外的效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
