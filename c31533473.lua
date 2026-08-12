--道化の一座 ディアボロ
-- 效果：
-- 相同属性而种族不同的怪兽×2
-- ①：上级召唤的自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的场上·墓地的融合怪兽全部回到额外卡组。
-- ●从卡组把1张「道化一座」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果，启用复活限制，添加融合召唤手续，创建贯穿伤害效果和解放时发动的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加需要2个满足s.ffilter条件的怪兽作为融合素材的融合召唤手续
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：上级召唤的自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果只对上级召唤的怪兽生效
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonType,SUMMON_TYPE_ADVANCE))
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数，用于判断是否可以作为融合召唤的素材
function s.ffilter(c,fc,sub,mg,sg)
	-- 如果当前融合素材组为空或没有元素，则返回true
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())
			and not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 用于筛选场上或墓地中的融合怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_FUSION) and c:IsAbleToDeck()
end
-- 用于筛选可以盖放的「道化一座」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 处理解放时选择效果的函数，判断是否可以发动两个效果并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上或墓地是否存在融合怪兽
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil)
		-- 检查是否已使用过该效果（通过标识效果判断）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查玩家场上是否有足够的魔法陷阱区域
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在「道化一座」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查是否已使用过该效果（通过标识效果判断）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从两个效果中选择一个
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"回收融合怪兽"
			{b2,aux.Stringid(id,2),2})  --"盖放陷阱卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 注册标识效果，防止该效果在1回合内重复使用
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取场上或墓地中的所有融合怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 设置连锁操作信息，指定要送回额外卡组的卡
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SSET)
			-- 注册标识效果，防止该效果在1回合内重复使用
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 处理选择效果后的实际操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取场上或墓地中的所有融合怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 检查是否因王家长眠之谷而无法发动此效果
		if aux.NecroValleyNegateCheck(g) then return end
		-- 将符合条件的融合怪兽送回额外卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 检查玩家场上是否有足够的魔法陷阱区域
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择一张「道化一座」陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的陷阱卡在自己场上盖放
			Duel.SSet(tp,tc)
		end
	end
end
