--アーティファクト・ムーブメント
-- 效果：
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组选1只「古遗物」怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
-- ②：这张卡被对方破坏的场合发动。下次的对方战斗阶段跳过。
function c29223325.initial_effect(c)
	-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组选1只「古遗物」怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29223325,0))  --"跳过战斗阶段"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetTarget(c29223325.target)
	e1:SetOperation(c29223325.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合发动。下次的对方战斗阶段跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29223325,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c29223325.descon)
	e2:SetOperation(c29223325.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「古遗物」怪兽（种族为0x97，类型为怪兽，且可以特殊召唤）
function c29223325.filter(c)
	return c:IsSetCard(0x97) and c:IsType(TYPE_MONSTER) and c:IsSSetable(true)
end
-- 过滤函数，用于筛选满足条件的魔法·陷阱卡（类型为魔法或陷阱，且目标玩家的魔法与陷阱区域有足够空位）
function c29223325.desfilter(c,tp,ft)
	-- 判断目标卡是否为魔法或陷阱类型，并且目标玩家的魔法与陷阱区域有足够空位
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetSZoneCount(tp,c)>ft
end
-- 处理效果的发动条件，检查是否满足发动条件（卡组存在「古遗物」怪兽，且场上存在满足条件的魔法·陷阱卡）
function c29223325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c29223325.desfilter(chkc,tp,0) and chkc~=e:GetHandler() end
	if chk==0 then
		-- 检查卡组中是否存在至少1张满足filter条件的「古遗物」怪兽
		if not Duel.IsExistingMatchingCard(c29223325.filter,tp,LOCATION_DECK,0,1,nil) then return false end
		local ft=0
		if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
		-- 检查场上是否存在至少1张满足desfilter条件的魔法·陷阱卡
		return Duel.IsExistingTarget(c29223325.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),tp,ft)
	end
	-- 提示玩家选择要破坏的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c29223325.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),tp,0)
	-- 设置效果操作信息，标记将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的发动操作，破坏对象卡并从卡组特殊召唤「古遗物」怪兽
function c29223325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上，并且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查目标玩家的魔法与陷阱区域是否有空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要盖放的「古遗物」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足filter条件的「古遗物」怪兽
		local g=Duel.SelectMatchingCard(tp,c29223325.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「古遗物」怪兽特殊召唤到自己的魔法与陷阱区域盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 判断该卡是否被对方破坏且之前属于己方控制
function c29223325.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 处理效果的发动操作，跳过对方的战斗阶段
function c29223325.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 创建一个用于跳过对方战斗阶段的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前回合玩家是否不是效果持有者，且当前阶段在主要阶段1和主要阶段2之间
	if Duel.GetTurnPlayer()~=tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
		-- 记录当前回合数，用于后续判断是否跳过战斗阶段
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c29223325.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	-- 将创建的效果注册到目标玩家的场上
	Duel.RegisterEffect(e1,tp)
end
-- 跳过战斗阶段效果的条件函数，判断是否应跳过战斗阶段
function c29223325.skipcon(e)
	-- 判断当前回合数是否与记录的回合数不同，用于确定是否跳过战斗阶段
	return Duel.GetTurnCount()~=e:GetLabel()
end
