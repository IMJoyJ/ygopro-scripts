--烙印喪失
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
function c10065487.initial_effect(c)
	-- ①：以自己场上1只融合怪兽和从额外卡组特殊召唤的对方场上1只怪兽为对象才能发动。那些怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10065487+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10065487.target)
	e1:SetOperation(c10065487.activate)
	c:RegisterEffect(e1)
end
-- 自己融合怪兽的过滤条件函数：自己场上表侧表示的融合怪兽
function c10065487.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 对方怪兽的过滤条件函数：从额外卡组特殊召唤且可以回到卡组的怪兽
function c10065487.filter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 效果①的发动效果目标（Target）处理：选择自己场上1只表侧融合怪兽和对方场上1只从额外卡组特召的怪兽为对象，并设定效果分类信息
function c10065487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在表侧表示的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c10065487.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在从额外卡组特殊召唤且可以回到卡组的怪兽
		and Duel.IsExistingTarget(c10065487.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择要返回卡组的第一张卡片（融合怪兽）的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上的1只融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10065487.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 给玩家发送选择要返回卡组的第二张卡片（对方额外特召怪兽）的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上的1只从额外卡组特殊召唤的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c10065487.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:Merge(g2)
	-- 设置效果处理信息为将选中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果①的效果处理（Operation）函数：使选中的怪兽回到持有者卡组，并在本回合的结束阶段注册双方特殊召唤怪兽的效果
function c10065487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片组中仍与效果有关联的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象怪兽送回持有者卡组并洗卡，若成功则注册结束阶段特殊召唤的效果
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 这个回合的结束阶段，双方各自可以从自身的额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c10065487.endop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册一个在本回合结束阶段触发的事件监听器以执行后续的特殊召唤效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段的特殊召唤效果执行函数：依次让回合玩家及对方玩家进行特殊召唤的选择与处理
function c10065487.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 在画面上高亮并提示本卡发动的动画效果
	Duel.Hint(HINT_CARD,0,10065487)
	-- 获取当前的回合玩家作为首个进行特殊召唤选择的玩家
	local p=Duel.GetTurnPlayer()
	c10065487.spop(e,p)
	p=1-p
	c10065487.spop(e,p)
end
-- 用于特殊召唤的融合怪兽过滤条件函数：融合怪兽、将「阿不思的落胤」记述为融合素材、可以特殊召唤且额外卡组区域有空位
function c10065487.spfilter(c,e,tp)
	-- 检查卡片是否为融合怪兽且是否以「阿不思的落胤」（卡号68468459）为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 检查该融合怪兽是否可以被特殊召唤，以及玩家场上是否有空余的额外怪兽召唤区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 为指定玩家进行特殊召唤的选择与操作函数
function c10065487.spop(e,p)
	-- 检查该玩家额外卡组中是否存在可特殊召唤的以「阿不思的落胤」为融合素材的融合怪兽
	if Duel.IsExistingMatchingCard(c10065487.spfilter,p,LOCATION_EXTRA,0,1,nil,e,p)
		-- 让玩家选择是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽
		and Duel.SelectYesNo(p,aux.Stringid(10065487,1)) then  --"是否特殊召唤以「阿不思的落胤」为融合素材的融合怪兽？"
		-- 给玩家发送选择特殊召唤怪兽的系统提示
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组中选择1只满足条件的融合怪兽
		local g=Duel.SelectMatchingCard(p,c10065487.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p)
		-- 将选择的融合怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end
