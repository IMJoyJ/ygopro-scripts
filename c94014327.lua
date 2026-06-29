--破械焔魔天ヤマ
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（包括连接召唤素材限制，自己结束阶段特殊召唤墓地本回合被破坏的最多2只恶魔族怪兽且限制后续特召为恶魔族的效果，以及在被破坏时可用场上1张表侧表示卡片代替破坏的代替破坏效果）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续，要求使用2-4只怪兽作为素材，且素材中必须包含「破械神」怪兽
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	-- 自己结束阶段，以这个回合被破坏的自己墓地最多2只恶魔族怪兽为对象可以发动。那些怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是恶魔族怪兽不能特殊召唤
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
	-- 场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己或对方场上1张表侧表示卡片破坏
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
-- 连接召唤素材中必须包含至少1只「破械神」怪兽的检查条件函数
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1130)
end
-- 效果①特殊召唤效果的发动条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 过滤本回合被破坏、属于恶魔族且可以特殊召唤的墓地怪兽的过滤函数
function s.spfilter(c,e,tp,cid)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==cid and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①特殊召唤效果的发动准备与取对象函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的回合数
	local cid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,cid) end
	-- 获取当前玩家的可使用怪兽区域空位数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 在chk==0时，检查是否有空余的怪兽区域且怪兽限制数量大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0
		-- 并且检查自己墓地中是否存在满足特殊召唤条件的目标怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,cid) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在墓地选择最多两个满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp,cid)
	-- 设置效果处理的分类为特殊召唤，并将选定的卡牌组和数量加入到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果①特殊召唤与特召后限制的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的可使用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if ft>0 and g:GetCount()>0 and
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		not (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		if g:GetCount()>ft then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		-- 遍历所有满足条件的特殊召唤对象怪兽
		for tc in aux.Next(g) do
			-- 将目标怪兽以表侧表示特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是恶魔族怪兽不能特殊召唤
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
		-- 完成本批次的所有特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制玩家不能特殊召唤恶魔族以外怪兽的过滤限制函数
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 过滤场上表侧表示可以作为代替破坏的卡片的过滤函数
function s.repfilter(c,e)
	return c:IsFaceup()
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的发动准备与检查函数
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 并且检查场上是否存在其他表侧表示且可被效果破坏的卡片
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,e) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择场上1张符合代替破坏条件的卡
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,e)
		-- 将选中的代替卡牌设定为效果对象
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为代替破坏对象的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 作为代替，将选择的卡片用效果破坏
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
