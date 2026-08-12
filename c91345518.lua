--裁きの代行者 サターン
-- 效果：
-- ①：把这张卡解放才能发动。自己基本分比对方多的场合，给与对方那个相差数值的伤害。这个效果在自己场上有「天空的圣域」存在的场合才能发动和处理。这个效果发动的回合，自己不能进行战斗阶段。
function c91345518.initial_effect(c)
	-- 在卡片中记录关联卡片「天空的圣域」的卡名
	aux.AddCodeList(c,56433456)
	-- ①：把这张卡解放才能发动。自己基本分比对方多的场合，给与对方那个相差数值的伤害。这个效果在自己场上有「天空的圣域」存在的场合才能发动和处理。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91345518,0))  --"给与对方基本分差值的伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c91345518.damcost)
	e1:SetTarget(c91345518.damtg)
	e1:SetOperation(c91345518.damop)
	c:RegisterEffect(e1)
end
-- 定义效果发动代价函数，处理解放自身以及不能进行战斗阶段的限制
function c91345518.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：当前不是主要阶段2（因为不能进行战斗阶段，若在主2发动则无法进入战斗阶段的誓约无法达成），且自身可以被解放
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 and e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 自己基本分比对方多的场合，给与对方那个相差数值的伤害。这个效果在自己场上有「天空的圣域」存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 在全局注册该玩家本回合不能进行战斗阶段的效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义效果的目标函数，检查基本分差值与场地卡条件，并设置伤害操作信息
function c91345518.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：自己的基本分比对方多
	if chk==0 then return Duel.GetLP(tp)>Duel.GetLP(1-tp)
		-- 且自己场上有「天空的圣域」存在
		and Duel.IsEnvironment(56433456,tp) end
	-- 设置对方玩家为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息为给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 定义效果的处理函数，计算基本分差值并给与对方伤害
function c91345518.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有「天空的圣域」存在，则不进行处理
	if not Duel.IsEnvironment(56433456,tp) then return end
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算双方基本分的差值
	local val=Duel.GetLP(1-p)-Duel.GetLP(p)
	if val>0 then
		-- 给与目标玩家该差值数值的伤害
		Duel.Damage(p,val,REASON_EFFECT)
	end
end
