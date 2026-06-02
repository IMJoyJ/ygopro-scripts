--絶境なる獄神域－ヴィライア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」各1只从自己的额外卡组·场上（表侧表示）·墓地选出给双方确认，这个回合，对方不能对应自己的「狱神」怪兽的效果的发动把效果发动。
-- ②：为让自己场上的「狱神」怪兽的效果发动而从卡组上面把卡除外的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 初始化效果：注册添加卡片密码记录、卡片发动时的展示确认并锁链效果，以及在墓地作为「狱神」怪兽效果发动时代替卡组除外代价的效果
function s.initial_effect(c)
	-- 建立这张卡记述了创狱神、坏狱神、调狱神关联卡片密码的列表
	aux.AddCodeList(c,53589300,68231287,5914858)
	-- ①：「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」各1只从自己的额外卡组·场上（表侧表示）·墓地选出给双方确认，这个回合，对方不能对应自己的「狱神」怪兽的效果的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：为让自己场上的「狱神」怪兽的效果发动而从卡组上面把卡除外的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"是否作为代替把「绝境的狱神域-威利亚」除外？"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(id)
	e2:SetCountLimit(1,id+o)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索额外卡组、场上（表侧表示）或墓地中卡名为「创狱神 涅瓦」、「坏狱神 朱庇特」或「调狱神 朱诺拉」的卡片
function s.cfilter(c,tp)
	return (c:IsLocation(LOCATION_EXTRA) or c:IsFaceupEx()) and c:IsCode(53589300,68231287,5914858)
end
-- 卡片发动时的Target函数，检索符合展示条件的所有卡片，并检查是否可选择3张卡名各不相同的卡片进行展示
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取以该玩家来看的额外卡组、场上、墓地中满足展示过滤条件的卡片组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 当chk为0时，检查是否本回合未使用过此效果，且上述卡片组中存在3张卡名不同的卡可以组成子组
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and g:CheckSubGroup(aux.dncheck,3,3) end
end
-- 卡片发动时的Operation函数，让玩家选择3只卡名互不相同的目标怪兽给双方确认，若包含额外卡组的卡则洗切额外卡组，并注册本回合对方不能对应自己「狱神」怪兽效果发动而发动效果的全局效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组、场上及墓地中满足展示条件的卡片组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 检查是否本回合未使用过该效果，且展示用的卡片组是否依然能选出3种不同的怪兽，若不能则不处理
	if Duel.GetFlagEffect(tp,id)==0 and g:CheckSubGroup(aux.dncheck,3,3) then
		-- 向玩家发送请选择要确认的卡的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让玩家从满足条件的卡中选择3张卡名互不相同的卡片
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3,nil)
		-- 给对方确认选中的3张卡片
		Duel.ConfirmCards(1-tp,sg)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then
			-- 若被确认的卡片中存在来自额外卡组的卡，则洗切额外卡组
			Duel.ShuffleExtra(tp)
		end
		-- 这个回合，对方不能对应自己的「狱神」怪兽的效果的发动把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.actop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局环境注册本回合生效的限制链发动效果
		Duel.RegisterEffect(e1,tp)
		-- 为玩家注册本回合已使用「绝境的狱神域-威利亚」①效果的全局Flag
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 锁链限制效果的Operation函数，当自己发动「狱神」怪兽的效果时限制对方玩家进行连锁发动
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:GetHandler():IsSetCard(0x1ce) and re:IsActiveType(TYPE_MONSTER) then
		-- 设定连锁限制函数
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 锁链限制条件函数，指定只有发动玩家可以进行连锁（即对方不能连锁）
function s.chainlm(e,rp,tp)
	return tp==rp
end
