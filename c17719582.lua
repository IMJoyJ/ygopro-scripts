--アルトメギア・ペリペティア－激動－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：以对方墓地1只怪兽为对象才能发动。自己场上1只「神艺」怪兽回到手卡·额外卡组，作为对象的怪兽效果无效在自己场上特殊召唤。
-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」魔法卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 在卡片中记录关联卡名「神艺学都 神艺学园」
	aux.AddCodeList(c,74733322)
	-- ①：以对方墓地1只怪兽为对象才能发动。自己场上1只「神艺」怪兽回到手卡·额外卡组，作为对象的怪兽效果无效在自己场上特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」魔法卡加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收魔法"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 设定此卡效果发动的回合，特殊召唤额外卡组怪兽限制的计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤不是从额外卡组特殊召唤的怪兽或者是表侧表示的融合怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 效果发动的Cost，检查本回合是否特殊召唤过融合怪兽以外的额外卡组怪兽，并施加不能从额外卡组特殊召唤融合怪兽以外怪兽的誓约
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否从额外卡组特殊召唤过融合怪兽以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：以对方墓地1只怪兽为对象才能发动。自己场上1只「神艺」怪兽回到手卡·额外卡组，作为对象的怪兽效果无效在自己场上特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册无法从额外卡组特殊召唤融合怪兽以外怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤融合怪兽以外怪兽的过滤函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤自己场上表侧表示、能回到手卡或额外卡组且空出主要怪兽区域的「神艺」怪兽
function s.thefilter(c,tp,chk)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and (c:IsAbleToHand() or c:IsAbleToExtra())
		-- 检查选择的怪兽离开场上后，是否能空出至少一个怪兽区域用于特殊召唤
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- ①效果的发动目标与检测函数，检查对方墓地是否有可以特殊召唤的目标以及自己场上是否有能返回手卡/额外卡组的「神艺」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 检查对方墓地是否存在可作为特殊召唤对象的目标
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
		-- 检查自己场上是否存在能返回手卡/额外卡组且能空出怪兽区域的「神艺」怪兽
		and Duel.IsExistingMatchingCard(s.thefilter,tp,LOCATION_MZONE,0,1,nil,tp,true) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理函数，将自己场上1只「神艺」怪兽返回手卡/额外卡组，并将对方墓地的目标怪兽效果无效在自己场上特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要返回手牌或额外卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local rg=nil
	-- 如果存在能让出怪兽区域的「神艺」怪兽
	if Duel.IsExistingMatchingCard(s.thefilter,tp,LOCATION_MZONE,0,1,nil,tp,true) then
		-- 优先选择能让出怪兽区域的「神艺」怪兽
		rg=Duel.SelectMatchingCard(tp,s.thefilter,tp,LOCATION_MZONE,0,1,1,nil,tp,true)
	else
		-- 如果不需要特意让出区域，则任意选择1只「神艺」怪兽
		rg=Duel.SelectMatchingCard(tp,s.thefilter,tp,LOCATION_MZONE,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		-- 对选中的「神艺」怪兽进行选定提示
		Duel.HintSelection(rg)
		-- 将选中的「神艺」怪兽送回手卡或额外卡组，并确认卡片是否成功回到对应位置
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)~=0 and rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA)
			-- 且对象怪兽仍与该连锁关联并符合王家长眠之谷的过滤规则
			and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
			-- 并且尝试将作为对象的怪兽以表侧表示在自己场上特殊召唤
			and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 作为对象的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 作为对象的怪兽效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的启动条件检查函数，检查此卡是否是为了让「神艺学都 神艺学园」的效果发动被送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:GetHandler():IsCode(74733322)
end
-- 过滤自己墓地或除外状态的「神艺」魔法卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1cd) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的发动目标检测，检查是否存在可加入手牌的目标并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地或除外状态是否存在可以加入手牌的「神艺」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的效果处理函数，将自己墓地或除外状态的1张「神艺」魔法卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地或除外状态符合条件的1张「神艺」魔法卡并应用王家长眠之谷的过滤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
