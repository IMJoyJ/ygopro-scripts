--ホロウヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，从对方卡组上面把最多6张卡翻开，从那之中选1张除外，剩余用原本的顺序回到卡组上面。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「空尖弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建效果，使空尖弹丸龙在场上的连接怪兽效果发动时可以破坏自身并翻开对方卡组最多6张卡，从中除外一张，其余按原顺序放回卡组
function s.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，从对方卡组上面把最多6张卡翻开，从那之中选1张除外，剩余用原本的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外卡组"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「空尖弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
-- 判断连锁是否为连接怪兽的效果，且该卡为对象
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 设置效果目标为破坏自身和除外对方卡组的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方卡组最上方一张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 and g:GetFirst():IsAbleToRemove(tp) end
	-- 设置操作信息为除外对方卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	-- 设置操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- 处理效果发动，先破坏自身，再翻开对方卡组并除外一张卡
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身在连锁中且成功破坏
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 获取己方卡组剩余卡数
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		if ct>5 then ct=6 end
		if ct>1 then
			-- 获取对方卡组最上方一张卡
			local cg=Duel.GetDecktopGroup(1-tp,1)
			if not cg:GetFirst():IsAbleToRemove(tp) then
				return
			end
			local tbl={}
			for i=1,ct do
				table.insert(tbl,i)
			end
			-- 提示玩家选择翻开的卡数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要翻开的卡的数量"
			-- 让玩家宣言翻开的卡数量
			ct=Duel.AnnounceNumber(tp,table.unpack(tbl))
		end
		-- 中断当前效果处理，使后续操作不与当前连锁同时处理
		Duel.BreakEffect()
		-- 确认对方卡组最上方指定数量的卡
		Duel.ConfirmDecktop(1-tp,ct)
		-- 获取对方卡组最上方指定数量的卡
		local g=Duel.GetDecktopGroup(1-tp,ct)
		-- 提示玩家选择除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 开始显示对方卡组翻开动画
		Duel.RevealSelectDeckSequence(true)
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp)
		-- 结束显示对方卡组翻开动画
		Duel.RevealSelectDeckSequence(false)
		if #sg>0 then
			-- 禁止后续操作自动洗切卡组
			Duel.DisableShuffleCheck(true)
			-- 将选中的卡除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 注册效果，使空尖弹丸龙在被破坏送入墓地时，在结束阶段触发特殊召唤效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 从卡组把「空尖弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,id+o)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(s.sptg)
		e1:SetOperation(s.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 定义过滤函数，筛选「弹丸」属性且非本卡的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果，从卡组选择符合条件的怪兽并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位可召唤怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
