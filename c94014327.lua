--破械焔魔天ヤマ
-- 效果：
-- 包含「破械神」怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己结束阶段，以这个回合被破坏的自己墓地最多2只恶魔族怪兽为对象才能发动。那些怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己或对方的场上1张表侧表示卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：启用苏生限制，添加连接召唤手续，注册①效果（自己结束阶段触发的诱发选发效果，取对象、特殊召唤分类，1回合1次）和②效果（场上的永续代替破坏效果，不入连锁，1回合1次）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：以2-4只怪兽作为连接素材，且素材中必须包含满足s.lcheck条件的怪兽（即「破械神」怪兽）
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	-- ①：自己结束阶段，以这个回合被破坏的自己墓地最多2只恶魔族怪兽为对象才能发动。那些怪兽特殊召唤。这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己或对方的场上1张表侧表示卡破坏。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 连接素材检查条件：素材组中至少存在1只「破械神」系列（0x1130）的怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1130)
end
-- ①效果的发动条件：当前回合玩家是自己，即只在自己的结束阶段才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（自己结束阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤对象的过滤条件：这个回合被破坏的恶魔族怪兽，并且可以被特殊召唤
function s.spfilter(c,e,tp,cid)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==cid and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的对象选择阶段：取得当前回合数，计算可特殊召唤的数量上限（取场上空格数与2的较小值，受「青眼精灵龙」影响时最多1只），并检测发动条件是否满足
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于判定怪兽是否是这个回合被破坏的
	local cid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,cid) end
	-- 获取自己场上主要怪兽区可用的空格数，作为可特殊召唤数量的上限
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 发动条件检测：自己场上存在可用的主要怪兽区空格，且可特殊召唤数量大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0
		-- 且自己墓地存在至少1只满足条件的、可以成为效果对象的恶魔族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,cid) end
	-- 向玩家发送提示消息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己墓地选择1-ct只满足条件的恶魔族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp,cid)
	-- 设置当前连锁的操作信息：特殊召唤分类，处理对象为选择的卡及其数量，供其他效果检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ①效果的处理：确认场上空格数并取得仍与本连锁相关的对象卡（过滤受「王家长眠之谷」影响的卡），数量超过空格数时由玩家补选，然后逐只以表侧表示特殊召唤，并给每只特殊召唤的怪兽附加特殊召唤限制和客户端提示
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区当前可用的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 取得与当前连锁相关的对象卡片组，并过滤掉受「王家长眠之谷」影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if ft>0 and g:GetCount()>0 and
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		not (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		if g:GetCount()>ft then
			-- 向玩家发送提示消息：请选择要特殊召唤的卡（对象数量多于空格数时）
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		-- 遍历要特殊召唤的怪兽组中的每一只怪兽
		for tc in aux.Next(g) do
			-- 以表侧表示将该怪兽特殊召唤到场上（单步特殊召唤，用于同时特殊召唤多只怪兽）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「破械焰魔天 阎摩」的效果特殊召唤"
		end
		-- 完成本次特殊召唤处理（与Duel.SpecialSummonStep配套，结算同时特殊召唤的多只怪兽）
		Duel.SpecialSummonComplete()
	end
end
-- 特殊召唤限制的过滤条件：不是恶魔族的怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 代替破坏对象的过滤条件：场上表侧表示、可以被效果破坏且尚未处于破坏确定状态的卡
function s.repfilter(c,e)
	return c:IsFaceup()
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- ②效果的发动条件检测：这张卡是因战斗或效果被破坏（且本次不是代替破坏），并且场上存在可用于代替破坏的卡
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 且双方场上存在至少1张这张卡以外的、满足条件的可代替破坏的表侧表示卡
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向玩家发送提示消息：请选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让自己选择双方场上1张这张卡以外的、可代替破坏的表侧表示卡
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,e)
		-- 将选择的卡设置为当前连锁的对象
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- ②效果的处理：取得当前连锁的对象卡，解除其破坏确定状态后将其以效果破坏，作为这张卡被破坏的代替
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片组（即发动时选择的用于代替破坏的卡）
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏该卡（标记为代替破坏），代替这张卡被破坏
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
