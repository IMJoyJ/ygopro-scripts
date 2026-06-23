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
		-- 记录场上被破坏的黑羽怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(c52900379.checkop)
		-- 注册用于记录破坏事件的效果
		Duel.RegisterEffect(ge1,0)
		-- 在抽卡阶段开始时重置计数器
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c52900379.clear)
		-- 注册用于重置计数器的效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 判断是否满足特殊召唤条件
function c52900379.spcon(e,c)
	if c==nil then return true end
	-- 检查是否有足够的怪兽区域和满足条件的黑羽怪兽数量
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and c52900379[c:GetControler()]>=2
end
-- 遍历被破坏的卡片并统计黑羽怪兽数量
function c52900379.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x33) and tc:IsFaceup() then
			c52900379[tc:GetControler()]=c52900379[tc:GetControler()]+1
		end
		tc=eg:GetNext()
	end
end
-- 清空黑羽怪兽计数器
function c52900379.clear(e,tp,eg,ep,ev,re,r,rp)
	c52900379[0]=0
	c52900379[1]=0
end
-- 判断是否为同调召唤素材并进入墓地
function c52900379.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 设置回复LP的效果目标
function c52900379.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为600
	Duel.SetTargetParam(600)
	-- 设置连锁操作信息，指定回复600基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end
-- 执行回复LP的操作
function c52900379.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
