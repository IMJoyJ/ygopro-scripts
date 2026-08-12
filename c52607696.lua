--幻惑のバリア －ミラージュフォース－
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤，那只攻击怪兽回到手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的幻想魔族怪兽因对方的效果从场上离开的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化此卡的两个效果：e1为攻击宣言时发动的①效果（含特殊召唤和回手卡分类），e2为在墓地存在的离场触发②效果（1回合1次，代价是把这张卡除外），并分别注册到这张卡上。
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤，那只攻击怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的幻想魔族怪兽因对方的效果从场上离开的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤。（这个卡名的②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 设置②效果的发动代价：把墓地存在的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：本次攻击宣言的攻击怪兽由对方控制，即对方怪兽的攻击宣言时。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此次战斗进行攻击宣言的那只怪兽。
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- 特殊召唤对象的过滤条件：是幻想魔族怪兽，并且可以被这个效果特殊召唤。
function s.filter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检测：攻击怪兽仍与战斗相关且可以回到手卡，自己主要怪兽区有空位，且自己的手卡·墓地存在可以被特殊召唤的幻想魔族怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得此次攻击宣言的那只攻击怪兽。
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() and at:IsAbleToHand()
		-- 确认自己的主要怪兽区至少有1个可用空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己的手卡·墓地存在至少1只满足条件的幻想魔族怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：确定要将那只攻击怪兽回到手卡（回手牌效果的对象为攻击怪兽，数量1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,at,1,0,0)
	-- 设置操作信息：预计从自己的手卡·墓地特殊召唤1只怪兽（特殊召唤的具体卡在处理时才能确定，故对象为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的处理：主要怪兽区无空位则中断；提示并让自己从手卡·墓地选择1只幻想魔族怪兽（不受王家长眠之谷影响），特殊召唤成功后再确认攻击怪兽仍与战斗相关并将其效果送回持有者的手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时检查自己主要怪兽区是否还有空位，没有则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选卡提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己的手卡·墓地选择1只满足条件且不受王家长眠之谷影响的幻想魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若选出了卡且将其以表侧表示特殊召唤到自己场上成功，则继续处理攻击怪兽回手卡的部分。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 再次取得此次攻击宣言的那只攻击怪兽。
		local at=Duel.GetAttacker()
		if at:IsRelateToBattle() then
			-- 把那只攻击怪兽以效果原因送回其持有者的手卡。
			Duel.SendtoHand(at,nil,REASON_EFFECT)
		end
	end
end
-- ②效果触发的离场怪兽过滤条件：离场前是幻想魔族、原本由自己控制、离场前为表侧表示、因对方玩家的效果从自己的主要怪兽区离开。
function s.spcfilter(c,tp)
	return bit.band(c:GetPreviousRaceOnField(),RACE_ILLUSION)~=0 and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②效果的发动条件：本次离场的卡中存在至少1只满足条件的怪兽，即自己场上表侧表示的幻想魔族怪兽因对方的效果从场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
-- ②效果的发动检测：自己主要怪兽区有空位，且自己的手卡·墓地存在可以被特殊召唤的幻想魔族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得此次战斗攻击的怪兽（此处无实际用途，仅为沿用写法）。
	local at=Duel.GetAttacker()
	-- 发动检测时确认自己的主要怪兽区至少有1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己的手卡·墓地存在至少1只满足条件的幻想魔族怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己的手卡·墓地特殊召唤1只怪兽（具体卡在处理时才能确定，故对象为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的处理：主要怪兽区无空位则中断；提示并让自己从手卡·墓地选择1只幻想魔族怪兽（不受王家长眠之谷影响），将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时检查自己主要怪兽区是否还有空位，没有则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选卡提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己的手卡·墓地选择1只满足条件且不受王家长眠之谷影响的幻想魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选择的幻想魔族怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
