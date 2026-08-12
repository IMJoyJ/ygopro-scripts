--魔弾の悪魔 ザミエル
-- 效果：
-- 这张卡可以把1只「魔弹」怪兽解放表侧表示上级召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：对方结束阶段才能发动。自己从卡组抽出这个回合这张卡表侧表示存在期间自己发动的「魔弹」魔法·陷阱卡的数量。
function c30907810.initial_effect(c)
	-- 上级召唤效果，可以解放1只「魔弹」怪兽进行上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30907810,0))  --"把1只「魔弹」怪兽解放表侧表示上级召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c30907810.otcon)
	e1:SetOperation(c30907810.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30907810,2))  --"适用「魔弹恶魔 萨米尔」的效果来发动"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_MZONE)
	-- 设置效果目标为「魔弹」卡
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetValue(32841045)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e4)
	-- 对方结束阶段才能发动。自己从卡组抽出这个回合这张卡表侧表示存在期间自己发动的「魔弹」魔法·陷阱卡的数量
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetDescription(aux.Stringid(30907810,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,30907810)
	e5:SetCondition(c30907810.drcon)
	e5:SetTarget(c30907810.drtg)
	e5:SetOperation(c30907810.drop)
	c:RegisterEffect(e5)
	-- 连锁发动时记录「魔弹」魔法·陷阱卡的发动次数
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetLabelObject(e5)
	e6:SetOperation(c30907810.regop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_CHAIN_NEGATED)
	e7:SetOperation(c30907810.regop2)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e8:SetOperation(c30907810.clearop)
	c:RegisterEffect(e8)
end
-- 过滤函数，用于判断场上是否满足上级召唤条件的「魔弹」怪兽
function c30907810.otfilter(c,tp)
	return c:IsSetCard(0x108) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤条件，包括等级、祭品数量和是否有足够的祭品
function c30907810.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足上级召唤条件的「魔弹」怪兽组
	local mg=Duel.GetMatchingGroup(c30907810.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤条件
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤时选择并解放祭品
function c30907810.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足上级召唤条件的「魔弹」怪兽组
	local mg=Duel.GetMatchingGroup(c30907810.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 记录「魔弹」魔法·陷阱卡的发动次数
function c30907810.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x108) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		e:GetLabelObject():SetLabel(val+1)
	end
end
-- 当「魔弹」魔法·陷阱卡发动被无效时，减少记录的发动次数
function c30907810.regop2(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x108) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		if val==0 then val=1 end
		e:GetLabelObject():SetLabel(val-1)
	end
end
-- 每回合开始时清空记录的发动次数
function c30907810.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
-- 判断是否为对方回合
function c30907810.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 设置抽卡效果的目标和数量
function c30907810.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabel()
	-- 判断是否满足抽卡条件
	if chk==0 then return d>0 and Duel.IsPlayerCanDraw(tp,d) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
-- 执行抽卡效果
function c30907810.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取连锁中目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=e:GetLabel()
	if d>0 then
		-- 执行抽卡效果
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
