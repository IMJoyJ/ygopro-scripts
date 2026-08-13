--宝玉獣 ルビー・カーバンクル
-- 效果：
-- ①：这张卡特殊召唤成功时才能发动。自己的魔法与陷阱区域的「宝玉兽」怪兽卡尽可能特殊召唤。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c32710364.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c32710364.repcon)
	e1:SetOperation(c32710364.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时才能发动。自己的魔法与陷阱区域的「宝玉兽」怪兽卡尽可能特殊召唤。
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
-- 效果②的发动条件：必须是表侧表示的这张卡在主要怪兽区被破坏（由破坏原因导致其本应送去墓地）。
function c32710364.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 效果②处理：将这张卡变成永续魔法卡，使其不送去墓地，而是作为永续魔法卡留在自己的魔法与陷阱区域。
function c32710364.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 过滤自己魔法与陷阱区域中表侧表示且属于「宝玉兽」系列、可以被特殊召唤的怪兽卡。
function c32710364.filter(c,e,sp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- ①效果的发动条件和操作信息设定：发动时需要魔法与陷阱区域存在符合条件的「宝玉兽」怪兽且主要怪兽区有空位；并根据可用空格数与符合条件数量设置特殊召唤的操作信息。
function c32710364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否存在至少1只符合特殊召唤条件的「宝玉兽」怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32710364.filter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		-- 同时检查自己主要怪兽区是否至少存在1个可用格才能发动。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 获取自己主要怪兽区当前可用的空格数，作为当前能特殊召唤的最大数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 统计自己魔法与陷阱区域中符合特殊召唤条件的「宝玉兽」怪兽卡数量。
	local gct=Duel.GetMatchingGroupCount(c32710364.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	if ct>gct then
		-- 当可用空格数多于符合条件的卡数时，把操作信息设定为将全部符合条件的卡特殊召唤（数量为gct）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_SZONE)
	else
		-- 当可用空格数不足时，把操作信息设定为只将可用空格数（ct）张卡特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_SZONE)
	end
end
-- ①效果处理：获取可用怪兽区空格数，若为0则不处理；受青眼精灵龙限制时最多只能特殊召唤1只；选取魔陷区所有符合条件的「宝玉兽」怪兽，若数量不超过空格则全部特殊召唤，否则由玩家选择其中空格数张进行特殊召唤。
function c32710364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己主要怪兽区可用的空格数，用于决定实际特殊召唤的数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 获取自己魔法与陷阱区域中所有满足条件的「宝玉兽」怪兽卡集合。
	local g=Duel.GetMatchingGroup(c32710364.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	local gc=g:GetCount()
	if gc==0 then return end
	if gc<=ct then
		-- 将满足条件的全部「宝玉兽」怪兽卡以表侧攻击表示特殊召唤到自己场上（此时数量不超过可用格数）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 弹出特殊召唤选择提示，让玩家从符合条件的卡中选择需要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ct,ct,nil)
		-- 将玩家选出的对应数量的「宝玉兽」怪兽卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
