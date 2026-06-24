--破械焔魔天ヤマ
local s,id,o=GetID()
-- 初始化效果，启用复活限制并设置连接召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2到4张满足条件的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	-- 效果1：在结束阶段发动，可以特殊召唤符合条件的怪兽
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
	-- 效果2：代替破坏效果，可以将场上一张表侧表示的卡代替破坏
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
-- 连接召唤时必须包含一个炎之种族的链接怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1130)
end
-- 效果发动条件：当前回合玩家为效果使用者
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤过滤器函数，筛选被破坏且为恶魔族的怪兽
function s.spfilter(c,e,tp,cid)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==cid and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标选择函数，设置选择目标和检查条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数用于标记怪兽被破坏的回合
	local cid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,cid) end
	-- 获取玩家场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 判断是否满足发动条件：有空位且存在符合条件的目标
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0
		-- 检测是否存在满足特殊召唤条件的目标怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,cid) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp,cid)
	-- 设置操作信息，告知连锁将处理特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 特殊召唤执行函数，处理特殊召唤及后续限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取与当前连锁相关的选中目标组
	local g=Duel.GetTargetsRelateToChain()
	if ft>0 and g:GetCount()>0 and
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		not (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		if g:GetCount()>ft then
			-- 提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		-- 遍历目标怪兽组进行特殊召唤操作
		for tc in aux.Next(g) do
			-- 执行单张怪兽的特殊召唤步骤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 创建限制该怪兽不能再次特殊召唤的效果并注册
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
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
-- 限制效果：非恶魔族怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 代替破坏过滤器函数，筛选可被破坏的表侧表示卡
function s.repfilter(c,e)
	return c:IsFaceup()
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏目标选择函数，判断是否满足发动条件
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检测场上是否存在满足代替破坏条件的卡
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择一张满足条件的卡作为代替破坏对象
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,e)
		-- 设置当前连锁的目标卡为所选卡
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏执行函数，将目标卡破坏并替换原破坏效果
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果和代替破坏原因破坏目标卡
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
