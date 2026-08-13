--P.U.N.K.JAM FEVER!
-- 效果：
-- 8星怪兽×2
-- 「朋克即兴狂热！」1回合1次也能在自己场上的「朋克」融合·同调怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分，把这张卡1个超量素材取除才能发动。自己抽1张。
-- ②：自己墓地有念动力族·3星怪兽存在，这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 该函数初始化卡的召唤手续和两个效果：先添加“8星怪兽×2”的XYZ召唤手续，并允许在自己的「朋克」融合·同调怪兽上重叠作超量召唤；然后注册①抽卡效果和②无效并破坏效果的发动条件、代价与处理。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,8,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在「朋克」融合·同调怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：支付600基本分，把这张卡1个超量素材取除才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有念动力族·3星怪兽存在，这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"无效发动"
	e2:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 超量召唤手续的替代素材过滤函数：判定作为叠放对象的怪兽是否为表侧表示、属于「朋克」系列且为融合或同调怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 超量召唤手续的追加操作函数：若选择用「朋克」融合·同调怪兽重叠召唤，则检查本回合是否已经使用过该特殊召唤方式，并注册对应的誓约标记。
function s.xyzop(e,tp,chk)
	-- 在发动前检查本回合是否已经用「朋克」融合·同调怪兽进行过该卡的追加超量召唤，返回是否允许发动。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 在决斗者身上注册一个“本回合已使用过「朋克」融合·同调怪兽重叠召唤”的誓约标记，持续到结束阶段。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的代价函数：支付600基本分，并且取除这张卡的1个超量素材作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价发动前检查：这张卡是否有至少1个超量素材可取除，并且持有者能否支付600基本分。
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.CheckLPCost(tp,600) end
	-- 处理代价：从控制者处实际支付600基本分。
	Duel.PayLPCost(tp,600)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的目标与处理信息设定函数：效果处理时自己抽1张卡，并将抽卡对象和数量写入连锁信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查控制者是否可以抽1张卡作为发动的合法条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为效果发动者自身，供抽卡处理时确定抽牌玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息，声明本次效果将执行抽1张卡的操作，用于相关效果检测（如不能抽卡等）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果实际处理函数：根据之前设定的对象玩家和抽卡数量执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出目标玩家和目标参数，即抽卡的玩家和数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②效果的辅助过滤函数：判断怪兽是否为等级3且念动力族，用于检查墓地是否存在符合条件的怪兽。
function s.cfilter(c)
	return c:IsLevel(3) and c:IsRace(RACE_PSYCHO)
end
-- ②效果的发动条件：当前连锁可被无效，本卡未被战斗破坏；发动效果的怪兽不是本卡，且为怪兽效果；自己墓地存在等级3念动力族怪兽。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该连锁效果是否能被无效，并且这张卡自身没有被战斗破坏（保证能发动效果）。
	return Duel.IsChainNegatable(ev) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and re:GetHandler()~=c and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己墓地是否存在任意1只等级3的念动力族怪兽，作为②效果的发动前提。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- ②效果的代价函数：取除这张卡的1个超量素材作为发动代价。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的目标设定函数：无论何种情况都可发动，设定将使该怪兽效果无效并破坏的操作信息；若对象怪兽可破坏且与效果关联，则追加破坏信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明要把当前连锁的怪兽效果发动无效（对象为连锁的那组卡/效果）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该怪兽可被破坏且仍属于该效果的对象，则设置操作信息：声明要将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果实际处理函数：无效当前连锁的怪兽效果，并将对应的怪兽破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行发动无效；且确认该怪兽仍与所发动的效果关联（没有离场或失去对象）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效了效果的怪兽。
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
