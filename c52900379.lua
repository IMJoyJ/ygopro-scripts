--BF－追い風のアリゼ
-- 效果：
-- 自己场上表侧表示存在的名字带有「黑羽」的怪兽有2只以上被破坏的回合，这张卡可以从手卡特殊召唤。这张卡作为同调召唤的素材送去墓地的场合，自己回复600基本分。
function c52900379.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「黑羽」的怪兽有2只以上被破坏的回合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52900379.spcon)
	c:RegisterEffect(e1)
	-- 这张卡作为同调召唤的素材送去墓地的场合，自己回复600基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52900379,0))  --"回复600LP"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c52900379.reccon)
	e2:SetTarget(c52900379.rectg)
	e2:SetOperation(c52900379.recop)
	c:RegisterEffect(e2)
	if not c52900379.global_check then
		c52900379.global_check=true
		c52900379[0]=0
		c52900379[1]=0
		-- 自己场上表侧表示存在的名字带有「黑羽」的怪兽有2只以上被破坏的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(c52900379.checkop)
		-- 将监听破坏事件的全局持续效果注册到整个决斗中，后续每当有卡片被破坏时触发checkop，用于统计本回合场上表侧表示的黑羽怪兽被破坏的数量。
		Duel.RegisterEffect(ge1,0)
		-- 自己场上表侧表示存在的名字带有「黑羽」的怪兽有2只以上被破坏的回合，这张卡可以从手卡特殊召唤。这张卡作为同调召唤的素材送去墓地的场合，自己回复600基本分。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c52900379.clear)
		-- 将抽卡阶段开始时清零黑羽破坏计数器的全局持续效果注册到决斗中，使计数只保留在当前回合，实现“回合”限制。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 特殊召唤规则的条件函数：c为nil时表示存在该规则特殊召唤方式；否则需要手卡持有者场上有空余的怪兽区，且本回合该玩家场上表侧表示的黑羽怪兽被破坏过2只以上。
function c52900379.spcon(e,c)
	if c==nil then return true end
	-- 检查是否有空余的怪兽区域可放置这张卡，并且该玩家本回合的“表侧表示黑羽怪兽被破坏次数”计数达到2次以上。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and c52900379[c:GetControler()]>=2
end
-- 破坏事件发生时遍历所有被破坏的卡，若该卡被破坏前位于怪兽区域、卡名属于「黑羽」且为表侧表示，则在其控制者对应的计数器上加1，用于记录该玩家本回合被破坏的黑羽怪兽数量。
function c52900379.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x33) and tc:IsFaceup() then
			c52900379[tc:GetControler()]=c52900379[tc:GetControler()]+1
		end
		tc=eg:GetNext()
	end
end
-- 在抽卡阶段开始时，将玩家0和玩家1的黑羽破坏计数均重置为0，确保统计只针对当前回合。
function c52900379.clear(e,tp,eg,ep,ev,re,r,rp)
	c52900379[0]=0
	c52900379[1]=0
end
-- 回复效果的发动手动条件：这张卡作为同调召唤素材被送去墓地，并且当前位于墓地，符合“作为同调召唤的素材送去墓地的场合”。
function c52900379.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 回复效果的目标设定：该效果不取对象，发动时确认自己为回复玩家，回复数值设为600，并登记操作信息为恢复基本分效果。
function c52900379.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自己，表示由自己回复基本分。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为600，表示回复数值为600。
	Duel.SetTargetParam(600)
	-- 登记效果处理时的操作信息：分类为回复基本分，不取对象，预计回复玩家为tp，回复数值为600。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end
-- 回复效果的实际处理：从当前连锁信息中取出对象玩家和回复数值，执行基本分回复。
function c52900379.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中同时读取效果的对象玩家与对象参数，分别赋给变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果作为原因让玩家p回复d点基本分，完成回复600基本分的处理。
	Duel.Recover(p,d,REASON_EFFECT)
end
