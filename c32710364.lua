--宝玉獣 ルビー・カーバンクル
-- 效果：
-- ①：这张卡特殊召唤成功时才能发动。自己的魔法与陷阱区域的「宝玉兽」怪兽卡尽可能特殊召唤。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c32710364.initial_effect(c)
	-- 效果原文内容：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c32710364.repcon)
	e1:SetOperation(c32710364.repop)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡特殊召唤成功时才能发动。自己的魔法与陷阱区域的「宝玉兽」怪兽卡尽可能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32710364,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c32710364.target)
	e2:SetOperation(c32710364.operation)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断是否满足效果发动条件，即此卡正面表示且在怪兽区域且因破坏而离场。
function c32710364.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 规则层面操作：将此卡变为永续魔法卡类型并注册效果。
function c32710364.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：将此卡变为永续魔法卡类型。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 规则层面操作：过滤函数，用于筛选满足条件的宝玉兽怪兽卡。
function c32710364.filter(c,e,sp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 规则层面操作：判断是否满足发动条件，即自己魔法与陷阱区域存在宝玉兽怪兽卡且有空位。
function c32710364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断自己魔法与陷阱区域是否存在宝玉兽怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32710364.filter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		-- 规则层面操作：判断自己怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 规则层面操作：获取自己怪兽区域的空位数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 规则层面操作：获取自己魔法与陷阱区域宝玉兽怪兽卡的数量。
	local gct=Duel.GetMatchingGroupCount(c32710364.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	if ct>gct then
		-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤的卡数量为gct。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_SZONE)
	else
		-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤的卡数量为ct。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_SZONE)
	end
end
-- 规则层面操作：执行特殊召唤操作，根据数量决定是否需要选择。
function c32710364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取自己怪兽区域的空位数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 规则层面操作：获取自己魔法与陷阱区域所有宝玉兽怪兽卡的集合。
	local g=Duel.GetMatchingGroup(c32710364.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	local gc=g:GetCount()
	if gc==0 then return end
	if gc<=ct then
		-- 规则层面操作：将所有符合条件的宝玉兽怪兽卡特殊召唤到自己怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 规则层面操作：提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ct,ct,nil)
		-- 规则层面操作：将选择的宝玉兽怪兽卡特殊召唤到自己怪兽区域。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
