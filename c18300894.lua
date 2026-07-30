--シルクボムモース
-- 效果：
-- 自己墓地有2只以上风属性怪兽存在，这张卡在自己手卡存在的场合：可以把这张卡特殊召唤，自己墓地1只风属性怪兽加入卡组洗切。
-- 这张卡召唤·特殊召唤的场合：可以把对方卡组最上面的卡给双方确认，根据那张卡的种类适用以下效果。
-- ●怪兽：那只怪兽当作永续魔法卡使用在对方的魔法与陷阱区域放置。
-- ●魔法·陷阱卡：那张卡除外。
-- 「丝爆弹蛾」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建效果，注册两个效果，一个是手牌特殊召唤效果，一个是召唤成功后确认对方卡组并处理的诱发效果
function s.initial_effect(c)
	-- 手牌特殊召唤效果，条件为己方墓地有2只以上风属性怪兽存在，发动时可以将此卡特殊召唤，并将己方墓地1只风属性怪兽加入卡组洗切
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 召唤成功后确认对方卡组最上方的卡并处理的效果，根据该卡种类决定效果处理方式
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"确认卡组"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.dktg)
	e2:SetOperation(s.dkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 判断己方墓地是否有2只以上风属性怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方墓地是否存在至少2只风属性怪兽
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,2,nil,ATTRIBUTE_WIND)
end
-- 定义风属性怪兽加入卡组的过滤条件
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeck()
end
-- 设置特殊召唤效果的目标和处理条件，包括场地上有空位、此卡可特殊召唤且墓地存在风属性怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取己方墓地所有满足风属性且能加入卡组的怪兽
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and #dg>0 end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置将风属性怪兽送回卡组的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤并处理将风属性怪兽送回卡组的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能参与特殊召唤且成功特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示选择要返回卡组的风属性怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择满足条件的风属性怪兽加入卡组
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 显示选中的怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的怪兽送回卡组并洗切
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 设置确认对方卡组最上方卡片效果的目标和处理条件，包括对方卡组有卡且己方魔法陷阱区有空间或可除外
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 检查己方魔法陷阱区是否有空间或己方可除外怪兽
		and (Duel.GetLocationCount(tp,LOCATION_SZONE,1-tp,r)>0 or Duel.IsPlayerCanRemove(tp))
	end
	-- 设置当前连锁的目标玩家为己方
	Duel.SetTargetPlayer(tp)
end
-- 定义用于判断是否能将卡片移至对方魔法陷阱区的过滤条件
function s.filter(c,p)
	local r=LOCATION_REASON_TOFIELD
	return not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 检查目标玩家的魔法陷阱区是否有空位
		and Duel.GetLocationCount(p,LOCATION_SZONE,1-p,r)>0
end
-- 执行确认对方卡组最上方卡片并根据其类型处理效果的操作
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认对方卡组最上方1张卡
	Duel.ConfirmDecktop(1-p,1)
	-- 获取对方卡组最上方1张卡组成的Group
	local g=Duel.GetDecktopGroup(1-p,1)
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		if g:IsExists(s.filter,1,nil,1-p,p) then
			local tc=g:GetFirst()
			-- 将该卡移至对方魔法陷阱区
			Duel.MoveToField(tc,p,1-p,LOCATION_SZONE,POS_FACEUP,true)
			-- 将该卡变为永续魔法卡类型
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		else
			-- 将该卡以规则原因送入墓地
			Duel.SendtoGrave(g,REASON_RULE,p)
		end
	elseif g:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP) and g:IsExists(Card.IsAbleToRemove,1,nil,p) then
		-- 将该卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT,p)
	end
end
