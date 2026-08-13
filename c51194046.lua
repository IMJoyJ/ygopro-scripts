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
	-- 为这张卡启用灵摆怪兽属性，使其可以在灵摆区作为灵摆刻度，并支持灵摆召唤及相关灵摆操作。
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
		-- ②：自己上级召唤成功的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c51194046.checkop)
		-- 将 ge1 注册为无持有者的场地持续效果，在双方场上发生通常召唤成功时触发 checkop，用于记录上级召唤解放的「机壳」怪兽数量。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_MSET)
		-- 将 ge2 注册为同样的场地持续效果，将触发时机改为怪兽放置成功（里侧表示的上级召唤），同样用于记录上级召唤解放的「机壳」怪兽数量。
		Duel.RegisterEffect(ge2,0)
		-- 这个回合自己为上级召唤而解放的「机壳」怪兽的数量
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD)
		ge3:SetCode(EFFECT_MATERIAL_CHECK)
		ge3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
		ge3:SetValue(c51194046.valcheck)
		-- 注册 ge3 作为素材检查效果，在怪兽使用素材时计算素材中「机壳」怪兽的数量并存入 Label，供后续统计上级召唤解放数使用。
		Duel.RegisterEffect(ge3,0)
		ge1:SetLabelObject(ge3)
		ge2:SetLabelObject(ge3)
		-- 这个回合
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge4:SetOperation(c51194046.clearop)
		-- 注册 ge4 为场地持续效果，在抽卡阶段开始时清零双方累计的「机壳」解放数，确保只在“这个回合”内统计。
		Duel.RegisterEffect(ge4,0)
	end
end
-- 该函数是①的适用判定：若将要特殊召唤的怪兽不是「机壳」字段（0xaa），则禁止其特殊召唤，实现“自己不是「机壳」怪兽不能特殊召唤”。
function c51194046.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 该函数在上级召唤（包含里侧放置的上级召唤）成功时触发，读取素材检查效果中记录的「机壳」素材数，累加到对应召唤玩家的当回合计数中。
function c51194046.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_ADVANCE) then
		local p=tc:GetSummonPlayer()
		c51194046[p]=c51194046[p]+e:GetLabelObject():GetLabel()
	end
end
-- 该函数是素材检查效果的值函数，统计这张卡作为素材时其素材中「机壳」怪兽的数量，并存入效果的 Label，供 checkop 读取。
function c51194046.valcheck(e,c)
	local ct=c:GetMaterial():FilterCount(Card.IsSetCard,nil,0xaa)
	e:SetLabel(ct)
end
-- 该函数在抽卡阶段开始时调用，将两名玩家的上级召唤解放「机壳」计数重置为0，确保②效果只计算“这个回合”内解放的「机壳」怪兽数量。
function c51194046.clearop(e,tp,eg,ep,ev,re,r,rp)
	c51194046[0]=0
	c51194046[1]=0
end
-- 该函数是②的发动条件：本回合玩家 tp 累计解放的「机壳」怪兽数量大于0，即“自己上级召唤成功的回合的结束阶段才能发动”。
function c51194046.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c51194046[tp]>0
end
-- 该函数是②的目标处理：在合法条件下确认玩家可以抽卡，并登记本次抽卡的操作信息；chk==0 时先行检查合法性。
function c51194046.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查（chk==0）时，确认玩家 tp 可以抽 c51194046[tp] 张卡，若不能则不允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c51194046[tp]) end
	-- 向连锁登记操作信息，声明本效果将让玩家 tp 抽 c51194046[tp] 张卡（分类为 CATEGORY_DRAW），供后续效果处理与卡组检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c51194046[tp])
end
-- 该函数是②的效果处理：执行抽卡，抽出本回合该玩家上级召唤解放的「机壳」怪兽数量的卡。
function c51194046.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 以 REASON_EFFECT 为抽卡原因，让玩家 tp 实际抽取 c51194046[tp] 张卡。
	Duel.Draw(tp,c51194046[tp],REASON_EFFECT)
end
