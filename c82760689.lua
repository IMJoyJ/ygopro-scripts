--宝札雲
-- 效果：
-- 发动回合中名字带有「云魔物」的同名怪兽有2只以上召唤·反转召唤·特殊召唤的场合，结束阶段时从自己卡组抽2张卡。
function c82760689.initial_effect(c)
	-- 发动回合中名字带有「云魔物」的同名怪兽有2只以上召唤·反转召唤·特殊召唤的场合，结束阶段时从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c82760689.activate)
	c:RegisterEffect(e1)
	if not c82760689.global_check then
		c82760689.global_check=true
		c82760689[0]=false
		c82760689[1]=Group.CreateGroup()
		c82760689[1]:KeepAlive()
		-- 召唤
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c82760689.checkop)
		-- 注册全局通常召唤成功检测效果
		Duel.RegisterEffect(ge1,0)
		-- 反转召唤
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge2:SetOperation(c82760689.checkop)
		-- 注册全局反转召唤成功检测效果
		Duel.RegisterEffect(ge2,0)
		-- 特殊召唤
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge3:SetOperation(c82760689.checkop)
		-- 注册全局特殊召唤成功检测效果
		Duel.RegisterEffect(ge3,0)
		-- 发动回合中
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge4:SetOperation(c82760689.clear)
		-- 注册全局回合开始清理检测数据的效果
		Duel.RegisterEffect(ge4,0)
	end
end
-- 检测召唤、反转召唤、特殊召唤的怪兽是否为「云魔物」怪兽，并记录其卡名以判断是否有同名怪兽被召唤2只以上
function c82760689.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if not c82760689[0] and tc:IsFaceup() and tc:IsSetCard(0x18) then
			if c82760689[1]:IsContains(tc) then c82760689[0]=true
			else c82760689[1]:AddCard(tc) end
		end
		tc=eg:GetNext()
	end
end
-- 在每个回合的抽卡阶段开始时，重置召唤记录和同名怪兽召唤标记
function c82760689.clear(e,tp,eg,ep,ev,re,r,rp)
	c82760689[0]=false
	c82760689[1]:Clear()
end
-- 魔法卡发动时，注册一个在结束阶段判断条件并抽卡的效果
function c82760689.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 结束阶段时从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c82760689.drcon)
	e1:SetOperation(c82760689.drop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段判断条件并抽卡的效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于检查卡片组中是否存在与指定卡同名的其他卡
function c82760689.filter(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 判断本回合中是否有名字带有「云魔物」的同名怪兽有2只以上召唤、反转召唤、特殊召唤
function c82760689.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c82760689[0] or c82760689[1]:IsExists(c82760689.filter,1,nil,c82760689[1])
end
-- 执行抽卡效果，从卡组抽2张卡
function c82760689.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
