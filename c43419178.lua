--鬼神 水子守命
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
-- ②：对方把怪兽的效果发动的场合，以自己的墓地·除外状态的1张「艮神鬼」陷阱卡为对象才能发动（场上的里侧表示卡是3张以上的场合，也能作为代替以自己墓地1张陷阱卡为对象）。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤程序并注册两个触发效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动的场合，以自己的墓地·除外状态的1张「艮神鬼」陷阱卡为对象才能发动（场上的里侧表示卡是3张以上的场合，也能作为代替以自己墓地1张陷阱卡为对象）。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「艮神鬼」卡
function s.tgfilter(c)
	return c:IsSetCard(0x1e4) and c:IsAbleToGrave()
end
-- 设置①效果的发动条件，检查是否能从卡组选择1张「艮神鬼」卡并从场上选择1张卡送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从卡组选择1张「艮神鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查是否能从场上选择1张卡送去墓地
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置①效果的处理信息，指定要处理的2张卡（1张来自卡组，1张来自场上）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_ONFIELD)
end
-- ①效果的发动处理，选择并送去墓地1张「艮神鬼」卡和1张场上卡
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张「艮神鬼」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认所选卡已成功送去墓地且在墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从场上选择1张卡送去墓地
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if sg:GetCount()>0 then
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 将场上选中的卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件，判断是否为对方怪兽效果发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤满足条件的「艮神鬼」陷阱卡（包括墓地和除外状态）
function s.setfilter(c,res)
	return c:IsFaceupEx() and (c:IsSetCard(0x1e4) or res and c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 设置②效果的发动条件，检查是否有符合条件的卡可作为对象
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查场上有3张以上里侧表示的卡
	local res=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,res) end
	-- 检查是否存在符合条件的「艮神鬼」陷阱卡作为对象
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,res) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择符合条件的「艮神鬼」陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,res)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 设置②效果的处理信息，指定要处理的卡（从墓地或除外状态取出）
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- ②效果的发动处理，将选中的卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡与当前连锁相关且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
