--破械焔魔天ヤマ
local s,id,o=GetID()
-- 初始化卡片效果，注册限制条件、连接召唤手续以及各个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册连接召唤手续
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	-- 自己回合的结束阶段，以自己墓地本回合被破坏的恶魔族怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽只要在场上表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	-- 这张卡被破坏的场合，作为代替可以把场上1张表侧表示的卡破坏。
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
-- 连接素材的检查条件，连接素材中必须包含至少1只「破械」怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1130)
end
-- 检查当前回合是否为自己回合作为结束阶段效果发动的条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前的回合玩家是否是自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤自己墓地中在本回合被破坏的恶魔族怪兽
function s.spfilter(c,e,tp,cid)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==cid and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 结束阶段特召效果的发动目标，计算可特召数量，检查墓地中是否存在符合条件的怪兽，并注册特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合的回合数
	local cid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,cid) end
	-- 获取自己场上空余的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 在发动检测时检查自己场上是否有空余的怪兽区域且可特召数量大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0
		-- 并且检查自己墓地中是否存在可以特殊召唤的符合条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,cid) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp,cid)
	-- 设置效果处理的操作信息为：特殊召唤所选的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 结束阶段特召效果的效果处理，将选中的墓地怪兽特殊召唤，并为其注册不能特召恶魔族以外怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取仍与效果关联且不受王家长眠之谷影响的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if ft>0 and g:GetCount()>0 and
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		not (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		if g:GetCount()>ft then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		-- 遍历所有符合条件的被选中的怪兽
		for tc in aux.Next(g) do
			-- 将怪兽以表侧表示逐步进行特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽只要在场上表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		end
		-- 完成怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制自己特殊召唤的怪兽种族必须为恶魔族
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 过滤场上可以代替破坏的表侧表示卡片
function s.repfilter(c,e)
	return c:IsFaceup()
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的发动目标，检查这张卡是否因战斗或效果将被破坏，以及场上是否有可以用来代替破坏的卡
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 在发动检测时检查场上是否存在除这张卡以外的可以代替破坏的表侧表示卡片
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,e) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择场上1张表侧表示的卡作为代替破坏的目标
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,e)
		-- 将选择的代替卡片设置为效果处理的对象
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的效果处理，将被选中的卡破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取代替破坏的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏被选作代替的卡片
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
