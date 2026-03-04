--魔救の奇石－ドラガイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只水属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
function c10286023.initial_effect(c)
	-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10286023,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10286023)
	e1:SetCondition(c10286023.drcon)
	e1:SetTarget(c10286023.drtg)
	e1:SetOperation(c10286023.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只水属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10286023,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,10286024)
	e2:SetTarget(c10286023.dttg)
	e2:SetOperation(c10286023.dtop)
	c:RegisterEffect(e2)
end
-- 定义效果条件判断函数，检查该卡是否通过「魔救」系列效果特殊召唤（通过检查怪兽是否属于0x140系列）
function c10286023.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- 定义抽卡效果的处理目标函数，用于检测和设置抽卡相关操作信息
function c10286023.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标处理阶段检查玩家是否可以抽卡（检查玩家是否有卡可抽且未被禁止抽卡）
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置操作信息：抽卡效果，目标是玩家，抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义抽卡效果的处理操作函数，实际执行抽卡效果
function c10286023.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和目标参数（即抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，让目标玩家抽取指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义筛选函数，用于过滤符合条件的怪兽（场上或墓地的水属性同调怪兽）
function c10286023.texfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 定义②效果的处理目标函数，检测对象选择和卡片移动相关操作
function c10286023.dttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c10286023.texfilter(chkc) and chkc~=c end
	-- 在目标处理阶段检查是否存在符合条件的对象（场上或墓地水属性同调怪兽）且本卡可以回卡组
	if chk==0 then return Duel.IsExistingTarget(c10286023.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择目标卡（选择对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 让玩家从符合条件的怪兽中选择1只作为对象
	local g=Duel.SelectTarget(tp,c10286023.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 设置操作信息：对象怪兽回到额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息：本卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 定义②效果的处理操作函数，执行怪兽回额外和本卡回卡组
function c10286023.dtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象卡（即玩家选择的水属性同调怪兽）
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡与效果关联且成功回到额外卡组，且本卡也与效果关联，则执行本卡回卡组操作
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将本卡回到卡组最上面
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
