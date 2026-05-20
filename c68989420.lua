--TG オーバー・ドラグナー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把「科技属」怪兽任意数量守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
-- ②：场上的这张卡被破坏的场合发动。自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（同调召唤成功时特召墓地「科技属」怪兽）和②效果（场上被破坏时抽卡）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把「科技属」怪兽任意数量守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡同调召唤成功。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤自身墓地中可以守备表示特殊召唤的「科技属」怪兽。
function s.filter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备：检查自身怪兽区域是否有空位，以及墓地中是否存在可特殊召唤的「科技属」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特召条件的「科技属」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤至少1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的处理：从墓地选择任意数量（不超过可用空格数）的「科技属」怪兽守备表示特殊召唤，并适用“直到回合结束时自己不是「科技属」怪兽不能特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1到ft张（ft为可用空格数）满足条件的「科技属」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。②：场上的这张卡被破坏的场合发动。自己抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置不能特殊召唤的怪兽过滤条件：非「科技属」怪兽。
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x27))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该不能特殊召唤非「科技属」怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件：这张卡被破坏前存在于场上。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的发动准备：设置抽卡的目标玩家为自己，抽卡数量为1张，并设置抽卡的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果影响的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果影响的目标参数为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息，表示玩家tp将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：获取目标玩家和抽卡数量，执行抽卡效果。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
