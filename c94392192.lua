--クシャトリラ・オーガ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1张「俱舍怒威族」陷阱卡加入手卡。
-- ③：这张卡的攻击宣言时或者对方把怪兽的效果发动的场合才能发动。从对方卡组上面把最多5张卡翻开，从那之中选1张里侧表示除外。剩下的卡用原本的顺序回到卡组上面。
function c94392192.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94392192,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94392192.spcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1张「俱舍怒威族」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94392192,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,94392192)
	e2:SetTarget(c94392192.thtg)
	e2:SetOperation(c94392192.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击宣言时……才能发动。从对方卡组上面把最多5张卡翻开，从那之中选1张里侧表示除外。剩下的卡用原本的顺序回到卡组上面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94392192,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1,94392193)
	e3:SetTarget(c94392192.rmtg)
	e3:SetOperation(c94392192.rmop)
	c:RegisterEffect(e3)
	-- ③：……或者对方把怪兽的效果发动的场合才能发动。从对方卡组上面把最多5张卡翻开，从那之中选1张里侧表示除外。剩下的卡用原本的顺序回到卡组上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94392192,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,94392193)
	e4:SetCondition(c94392192.rmcon)
	e4:SetTarget(c94392192.rmtg2)
	e4:SetOperation(c94392192.rmop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：检查自己场上是否存在怪兽以及是否有可用的怪兽区域
function c94392192.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤条件：卡组中属于「俱舍怒威族」且是陷阱卡、并且能加入手牌的卡
function c94392192.thfilter(c)
	return c:IsSetCard(0x189) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在符合条件的卡，并设置检索的操作信息
function c94392192.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1张符合条件的「俱舍怒威族」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94392192.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1张「俱舍怒威族」陷阱卡加入手牌并给对方确认
function c94392192.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「俱舍怒威族」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c94392192.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：可以被玩家里侧表示除外的卡
function c94392192.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 效果③（攻击宣言时）的发动准备：检查对方卡组最上方是否有卡且能被里侧表示除外，并设置除外的操作信息
function c94392192.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return #g>0 and g:GetFirst():IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 设置连锁的操作信息：从对方卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 效果③的效果处理：翻开对方卡组上方最多5张卡，选择1张里侧表示除外，其余按原顺序放回
function c94392192.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前玩家不能进行除外操作，则直接结束处理
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 获取对方卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct>5 then ct=5 end
	if ct>1 then
		local tbl={}
		for i=1,ct do
			table.insert(tbl,i)
		end
		-- 向玩家发送提示信息：请选择要翻开的卡的数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(94392192,3))  --"请选择要翻开的卡的数量"
		-- 让玩家宣言一个数字，作为要翻开的卡片数量
		ct=Duel.AnnounceNumber(tp,table.unpack(tbl))
	end
	-- 向双方玩家确认（翻开）对方卡组最上方的指定数量的卡
	Duel.ConfirmDecktop(1-tp,ct)
	-- 获取对方卡组最上方的指定数量 of 卡片组
	local g=Duel.GetDecktopGroup(1-tp,ct)
	-- 向玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 开启卡组顺序选择的显示（用于在翻开的卡中选择，不打乱原本顺序）
	Duel.RevealSelectDeckSequence(true)
	local sg=g:FilterSelect(tp,c94392192.rmfilter,1,1,nil,tp)
	-- 关闭卡组顺序选择的显示
	Duel.RevealSelectDeckSequence(false)
	if #sg>0 then
		-- 禁用接下来的洗牌检测，防止因从卡组除外卡片而导致系统自动洗牌
		Duel.DisableShuffleCheck(true)
		-- 将选中的卡片因效果里侧表示除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 效果③（对方发动怪兽效果时）的发动条件：对方玩家发动了怪兽的效果
function c94392192.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果③（对方发动怪兽效果时）的发动准备：检查发动者是否为对方、对方卡组是否有卡且能被里侧表示除外，并设置除外操作信息
function c94392192.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return rp==1-tp and #g>0 and g:GetFirst():IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 设置连锁的操作信息：从对方卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
