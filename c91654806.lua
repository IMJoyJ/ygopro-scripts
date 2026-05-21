--宇宙との交信
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把原本持有者是对方的自己场上1只怪兽送去墓地才能发动。从自己的手卡·墓地选1只机械族怪兽特殊召唤。
-- ②：自己场上有「人造人-念力震慑者」存在，对方抽卡阶段对方通常抽卡时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。抽到的卡给双方确认，宣言的种类的场合，这张卡送去墓地，自己从卡组抽1张。
function c91654806.initial_effect(c)
	-- 注册卡片密码，表示这张卡的效果中记有「人造人-念力震慑者」的卡名
	aux.AddCodeList(c,77585513)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：把原本持有者是对方的自己场上1只怪兽送去墓地才能发动。从自己的手卡·墓地选1只机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91654806,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,91654806)
	e1:SetCost(c91654806.spcost)
	e1:SetTarget(c91654806.sptg)
	e1:SetOperation(c91654806.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「人造人-念力震慑者」存在，对方抽卡阶段对方通常抽卡时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。抽到的卡给双方确认，宣言的种类的场合，这张卡送去墓地，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91654806,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,91654807)
	e2:SetCondition(c91654806.drcon)
	e2:SetTarget(c91654806.drtg)
	e2:SetOperation(c91654806.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本持有者是对方的自己场上的怪兽，且可以作为代价送去墓地，并且其离场后能腾出可用的怪兽区域
function c91654806.tgfilter(c,tp)
	-- 检查怪兽的原本持有者是否为对方、是否能作为代价送去墓地，以及该怪兽离场后自己场上是否有可用的怪兽区域
	return c:GetOwner()~=tp and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的启动代价（Cost）处理函数
function c91654806.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查自己场上是否存在满足送墓代价条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91654806.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1只满足条件的原本持有者为对方的自己场上怪兽
	local g=Duel.SelectMatchingCard(tp,c91654806.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：手卡或墓地的机械族怪兽，且可以被特殊召唤
function c91654806.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）处理函数
function c91654806.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已支付代价（Label为100表示正在进行发动检查，此时怪兽尚未送墓但已计入位置计算），或者当前自己场上是否有空余的怪兽区域
	local res=e:GetLabel()==100 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手卡或墓地是否存在可以特殊召唤的机械族怪兽
		return res and Duel.IsExistingMatchingCard(c91654806.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理（Operation）函数
function c91654806.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只机械族怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91654806.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示存在的「人造人-念力震慑者」
function c91654806.confilter(c)
	return c:IsFaceup() and c:IsCode(77585513)
end
-- 效果②的发动条件（Condition）检查函数
function c91654806.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方玩家在抽卡阶段进行的规则通常抽卡，且自己场上存在表侧表示的「人造人-念力震慑者」
	return ep~=tp and r==REASON_RULE and Duel.IsExistingMatchingCard(c91654806.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动准备（Target）处理函数
function c91654806.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否能送去墓地，且自己是否可以抽卡
	if chk==0 then return e:GetHandler():IsAbleToGrave() and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择卡片的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱），并将宣言的结果保存在Label中
	e:SetLabel(Duel.AnnounceType(tp))
	-- 设置送去墓地的操作信息，表示将此卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),0,0,0)
	-- 设置抽卡的操作信息，表示自己将抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,0)
end
-- 效果②的效果处理（Operation）函数
function c91654806.drop(e,tp,eg,ep,ev,re,r,rp)
	if not eg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then return end
	local opt=e:GetLabel()
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	-- 将对方抽到的卡给双方确认
	Duel.ConfirmCards(tp,g)
	-- 重新洗切对方的手卡
	Duel.ShuffleHand(1-tp)
	local res=false
	local tc=g:GetFirst()
	while tc do
		if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
			res=true
		end
		tc=g:GetNext()
	end
	local c=e:GetHandler()
	-- 如果宣言的种类正确，且成功将这张卡送去墓地
	if res and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
