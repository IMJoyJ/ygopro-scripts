--クリフォート・アセンブラ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：自己上级召唤成功的回合的结束阶段才能发动。自己从卡组抽出这个回合自己为上级召唤而解放的「机壳」怪兽的数量。
-- 【怪兽描述】
-- qliphoth.exe 中的 0x1i-666 确认到未处理的异常。
-- 写入位置 0x00-000 时发生访问冲突。
-- 您想忽略此错误并尝试继续吗? <Y/N>...[ ]
-- ===CARNAGE===
-- 恶gn善iod道ru知能oy似no相yr们gn我a与s经i已do人G那
-- 着doo活lfe远永rif就g吃n子i果r的b树o命t生t摘又n手a伸w他怕d恐n在a现
function c51194046.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c51194046.splimit)
	c:RegisterEffect(e2)
	-- ②：自己上级召唤成功的回合的结束阶段才能发动。自己从卡组抽出这个回合自己为上级召唤而解放的「机壳」怪兽的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51194046,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c51194046.drcon)
	e3:SetTarget(c51194046.drtg)
	e3:SetOperation(c51194046.drop)
	c:RegisterEffect(e3)
	if not c51194046.global_check then
		c51194046.global_check=true
		c51194046[0]=0
		c51194046[1]=0
		-- 记录上级召唤成功的怪兽数量，用于后续抽卡效果计算
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c51194046.checkop)
		-- 将效果注册到全局环境，用于监听通常召唤成功事件
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_MSET)
		-- 将效果注册到全局环境，用于监听放置怪兽事件
		Duel.RegisterEffect(ge2,0)
		-- 设置素材检查效果，用于统计手牌中「机壳」怪兽数量
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD)
		ge3:SetCode(EFFECT_MATERIAL_CHECK)
		ge3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
		ge3:SetValue(c51194046.valcheck)
		-- 将效果注册到全局环境，用于监听素材检查事件
		Duel.RegisterEffect(ge3,0)
		ge1:SetLabelObject(ge3)
		ge2:SetLabelObject(ge3)
		-- 设置阶段开始时的清空操作，用于重置上级召唤计数器
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge4:SetOperation(c51194046.clearop)
		-- 将效果注册到全局环境，用于监听抽卡阶段开始事件
		Duel.RegisterEffect(ge4,0)
	end
end
-- 限制非「机壳」怪兽不能特殊召唤
function c51194046.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 当上级召唤成功时，记录该玩家本次上级召唤所使用的「机壳」怪兽数量
function c51194046.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_ADVANCE) then
		local p=tc:GetSummonPlayer()
		c51194046[p]=c51194046[p]+e:GetLabelObject():GetLabel()
	end
end
-- 统计手牌中「机壳」怪兽的数量并设置为标签值
function c51194046.valcheck(e,c)
	local ct=c:GetMaterial():FilterCount(Card.IsSetCard,nil,0xaa)
	e:SetLabel(ct)
end
-- 在抽卡阶段开始时清空全局计数器
function c51194046.clearop(e,tp,eg,ep,ev,re,r,rp)
	c51194046[0]=0
	c51194046[1]=0
end
-- 判断是否可以发动效果，即该玩家在上级召唤成功过
function c51194046.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c51194046[tp]>0
end
-- 设置效果目标，准备进行抽卡操作
function c51194046.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c51194046[tp]) end
	-- 设置操作信息，表明将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c51194046[tp])
end
-- 执行抽卡操作
function c51194046.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行从卡组抽卡的效果
	Duel.Draw(tp,c51194046[tp],REASON_EFFECT)
end
