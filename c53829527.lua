--クリストロン・クラスター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「水晶机巧」卡不能用对方的效果除外。
-- ②：以场上1张表侧表示卡为对象才能发动（自己场上有「水晶机巧」同调怪兽存在的场合，这个效果的对象可以变成2张）。「水晶机巧晶簇」以外的自己的墓地·除外状态的1张「水晶机巧」卡回到卡组，作为对象的卡破坏。
local s,id,o=GetID()
-- 该函数为卡片注册三个效果：e1是魔法/陷阱卡发动所需的空效果，使此卡能发动；e2实现①效果，让我方场上的「水晶机巧」卡不能被对方效果除外；e3实现②效果，取对象破坏并回卡组，且1回合1次。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「水晶机巧」卡不能用对方的效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	-- ②：以场上1张表侧表示卡为对象才能发动（自己场上有「水晶机巧」同调怪兽存在的场合，这个效果的对象可以变成2张）。「水晶机巧晶簇」以外的自己的墓地·除外状态的1张「水晶机巧」卡回到卡组，作为对象的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"破坏"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- e2的Target判定条件：被保护的卡需是自己场上表侧表示的「水晶机巧」卡，且对方玩家因效果（非改变去向类重定向）除外这些卡时，该除外无效。
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xea) and c:IsFaceup()
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 判定是否存在表侧表示的「水晶机巧」同调怪兽，用于②效果能否选择2张对象。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xea) and c:IsType(TYPE_SYNCHRO)
end
-- 判定墓地/除外区的卡是否可作为②效果回卡组的对象：不能是本卡自身，须为表侧表示、属「水晶机巧」系列且能够回卡组。
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsFaceupEx() and c:IsSetCard(0xea) and c:IsAbleToDeck()
end
-- ②效果的发动准备：若chkc参数存在则只检查该卡是否为场上表侧表示；若本卡效果无效化则把自身排除在可破坏对象之外；若场上有水晶机巧同调怪兽则可选对象数变为2；在发动时确认存在可选的对象和可回卡组的水晶机巧卡。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	local ct=1
	-- 若自己场上有表侧表示的水晶机巧同调怪兽，则本效果可选择的对象数由1变成2。
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	-- 发动时检测：场上至少存在1张可被选择为对象的表侧表示卡（自动排除因无效化而不可选的自身）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg)
		-- 同时检测：自己的墓地或除外区存在至少1张满足回卡组条件的「水晶机巧」卡。
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 给出“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1～ct张场上表侧表示的卡作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,xg)
	-- 向连锁信息登记破坏分类，标明要破坏的对象组及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 向连锁信息登记回卡组分类，标明要从墓地/除外区返回卡组1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理：取回连锁对象并筛选仍与效果相关的卡；从自己墓地/除外区选取1张符合条件的「水晶机巧」卡返回卡组；若返回成功且对象仍存在于场上，则将对象破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 给出“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地/除外区选择1张符合条件的「水晶机巧」卡，过滤条件中包含对王家长眠之谷等效果的处理。
	local dg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if dg:GetCount()>0 then
		-- 为选中的回卡组卡播放选定动画。
		Duel.HintSelection(dg)
		-- 将选中的卡返回持有者卡组并洗切，检查是否实际有卡返回。
		if Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			and tg:GetCount()>0 then
			-- 因回卡组成功，将仍然与效果相关的对象卡破坏。
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
