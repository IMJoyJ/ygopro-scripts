--Silk Bomb Moth
-- 效果：
-- 自己墓地有2只以上风属性怪兽存在，这张卡在自己手卡存在的场合：可以把这张卡特殊召唤，自己墓地1只风属性怪兽加入卡组洗切。
-- 这张卡召唤·特殊召唤的场合：可以把对方卡组最上面的卡给双方确认，根据那张卡的种类适用以下效果。
-- ●怪兽：那只怪兽当作永续魔法卡使用在对方的魔法与陷阱区域放置。
-- ●魔法·陷阱卡：那张卡除外。
-- 「丝爆弹蛾」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建两个效果，分别对应手牌特殊召唤和召唤/特殊召唤时的卡组确认效果
function s.initial_effect(c)
	-- 自己墓地有2只以上风属性怪兽存在，这张卡在自己手卡存在的场合：可以把这张卡特殊召唤，自己墓地1只风属性怪兽加入卡组洗切。
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
	-- 这张卡召唤·特殊召唤的场合：可以把对方卡组最上面的卡给双方确认，根据那张卡的种类适用以下效果。●怪兽：那只怪兽当作永续魔法卡使用在对方的魔法与陷阱区域放置。●魔法·陷阱卡：那张卡除外。
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
-- 检查自己墓地是否存在至少2只风属性怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少2只风属性怪兽
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,2,nil,ATTRIBUTE_WIND)
end
-- 过滤风属性且能加入卡组的怪兽
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeck()
end
-- 设置特殊召唤和将怪兽送回卡组的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取满足条件的风属性怪兽数量
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查是否有足够的场上位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and #dg>0 end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置将怪兽送回卡组的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤和将怪兽送回卡组的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否能参与特殊召唤并执行特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要送回卡组的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择满足条件的风属性怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 显示选中的怪兽被选为对象
			Duel.HintSelection(g)
			-- 将选中的怪兽送回卡组并洗切
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 设置卡组确认效果的目标
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否至少有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 检查对方场上是否有空置的魔法与陷阱区域或自己是否能除外卡
		and (Duel.GetLocationCount(tp,LOCATION_SZONE,1-tp,r)>0 or Duel.IsPlayerCanRemove(tp))
	end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
end
-- 检查目标怪兽是否能放置于对方场上
function s.filter(c,p)
	local r=LOCATION_REASON_TOFIELD
	return not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 检查目标怪兽是否能放置于对方场上
		and Duel.GetLocationCount(p,LOCATION_SZONE,1-p,r)>0
end
-- 执行卡组确认和后续处理
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认对方卡组最上方的1张卡
	Duel.ConfirmDecktop(1-p,1)
	-- 获取对方卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(1-p,1)
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		if g:IsExists(s.filter,1,nil,1-p,p) then
			local tc=g:GetFirst()
			-- 将目标怪兽移至对方场上
			Duel.MoveToField(tc,p,1-p,LOCATION_SZONE,POS_FACEUP,true)
			-- 将目标怪兽变为永续魔法卡
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		else
			-- 将目标魔法或陷阱卡送入墓地
			Duel.SendtoGrave(g,REASON_RULE,p)
		end
	elseif g:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP) and g:IsExists(Card.IsAbleToRemove,1,nil,p) then
		-- 将目标魔法或陷阱卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT,p)
	end
end
