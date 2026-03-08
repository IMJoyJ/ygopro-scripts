--ヌメロン・カオス・リチューアル
-- 效果：
-- ①：自己场上的表侧表示的「混沌No.1 混沌源数门-空」被怪兽的效果破坏的回合，从自己墓地的卡以及除外的自己的卡之中以1张「源数网络」和4只「No.」超量怪兽为对象才能发动。从额外卡组把1只「混沌No.1000 梦幻虚神 原数天灵」变成攻击力10000/守备力1000特殊召唤，把作为对象的5张卡作为那超量素材。这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
function c41850466.initial_effect(c)
	-- 记录此卡关联的其他卡片编号，用于后续效果判定
	aux.AddCodeList(c,79747096,41418852,89477759)
	-- ①：自己场上的表侧表示的「混沌No.1 混沌源数门-空」被怪兽的效果破坏的回合，从自己墓地的卡以及除外的自己的卡之中以1张「源数网络」和4只「No.」超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c41850466.xyzcon)
	e1:SetTarget(c41850466.xyztg)
	e1:SetOperation(c41850466.xyzop)
	c:RegisterEffect(e1)
	if not c41850466.global_check then
		c41850466.global_check=true
		-- 当有怪兽被破坏时，检查是否为我方场上表侧表示的「混沌No.1 混沌源数门-空」被怪兽效果破坏，若是则为该玩家注册一个标识效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c41850466.checkop)
		-- 将标识效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：判断一张卡是否为我方场上表侧表示的「混沌No.1 混沌源数门-空」被怪兽效果破坏
function c41850466.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==79747096
		and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():IsActiveType(TYPE_MONSTER)
end
-- 处理被破坏的卡，为破坏者所属玩家注册标识效果
function c41850466.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c41850466.cfilter,nil)
	-- 遍历所有被破坏的卡
	for tc in aux.Next(g) do
		-- 为破坏者所属玩家注册标识效果，用于标记该玩家已触发此效果
		Duel.RegisterFlagEffect(tc:GetPreviousControler(),41850466,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断是否已触发此效果：检查当前玩家是否有标识效果
function c41850466.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否已触发此效果
	return Duel.GetFlagEffect(tp,41850466)>0
end
-- 过滤函数：判断一张卡是否为「No.」超量怪兽且可作为超量素材
function c41850466.xyzfilter1(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanOverlay() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 过滤函数：判断一张卡是否为「源数网络」且可作为超量素材
function c41850466.xyzfilter2(c)
	return c:IsCode(41418852) and c:IsCanOverlay() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 过滤函数：判断一张卡是否为「混沌No.1000 梦幻虚神 原数天灵」且可特殊召唤
function c41850466.xyzfilter3(c,e,tp)
	-- 判断一张卡是否为「混沌No.1000 梦幻虚神 原数天灵」且可特殊召唤
	return c:IsCode(89477759) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判断是否满足发动条件：选择1张「源数网络」和4只「No.」超量怪兽作为对象，并从额外卡组选择1只「混沌No.1000 梦幻虚神 原数天灵」
function c41850466.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足发动条件：选择1张「源数网络」作为对象
	if chk==0 then return Duel.IsExistingTarget(c41850466.xyzfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 检查是否满足发动条件：选择4只「No.」超量怪兽作为对象
		and Duel.IsExistingTarget(c41850466.xyzfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,nil)
		-- 检查是否满足发动条件：从额外卡组选择1只「混沌No.1000 梦幻虚神 原数天灵」
		and Duel.IsExistingMatchingCard(c41850466.xyzfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择1张「源数网络」作为对象
	local sg1=Duel.SelectTarget(tp,c41850466.xyzfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择4只「No.」超量怪兽作为对象
	local sg2=Duel.SelectTarget(tp,c41850466.xyzfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,4,nil)
	sg1:Merge(sg2)
	local g=sg1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #g>0 then
		-- 设置操作信息：将被作为超量素材的墓地卡设置为离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
	end
	-- 设置操作信息：将特殊召唤的怪兽设置为额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数：判断一张卡是否与当前效果相关且未被无效
function c41850466.mtfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 处理效果：选择并特殊召唤「混沌No.1000 梦幻虚神 原数天灵」，设置其攻击力和守备力，并将对象卡叠放
function c41850466.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只「混沌No.1000 梦幻虚神 原数天灵」进行特殊召唤
	local sg=Duel.SelectMatchingCard(tp,c41850466.xyzfilter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	-- 判断是否成功特殊召唤并进行后续处理
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置特殊召唤怪兽的攻击力为10000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(10000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetValue(1000)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		sc:RegisterEffect(e2)
		-- 获取当前连锁的对象卡组
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=tg:Filter(c41850466.mtfilter,nil,e)
		if #g==5 then
			-- 将对象卡叠放至特殊召唤的怪兽上
			Duel.Overlay(sc,g)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 设置效果：限制玩家在本回合只能进行一次召唤或特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetLabel(c41850466.getsummoncount(tp))
	e1:SetTarget(c41850466.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制召唤效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将限制特殊召唤效果注册到全局环境
	Duel.RegisterEffect(e2,tp)
	-- 设置效果：限制玩家在本回合只能进行一次召唤或特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetLabel(c41850466.getsummoncount(tp))
	e3:SetValue(c41850466.countval)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤次数效果注册到全局环境
	Duel.RegisterEffect(e3,tp)
end
-- 获取玩家在本回合已进行的召唤和特殊召唤次数
function c41850466.getsummoncount(tp)
	-- 获取玩家在本回合已进行的召唤和特殊召唤次数
	return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
-- 判断是否超过限制次数
function c41850466.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c41850466.getsummoncount(sump)>e:GetLabel()
end
-- 设置特殊召唤次数的限制值
function c41850466.countval(e,re,tp)
	if c41850466.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
