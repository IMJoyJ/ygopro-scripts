--E-HERO ヘル・ブラット
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ②：把这张卡解放让「英雄」怪兽上级召唤成功的回合的结束阶段发动。自己从卡组抽1张。
function c50304345.initial_effect(c)
	-- 效果原文内容：①：自己场上没有怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50304345.spcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：把这张卡解放让「英雄」怪兽上级召唤成功的回合的结束阶段发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetOperation(c50304345.regop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断是否满足特殊召唤条件，即己方场上没有怪兽且有可用召唤位置。
function c50304345.spcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查己方主要怪兽区域是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 规则层面操作：确认己方场上没有怪兽存在。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
-- 规则层面操作：当此卡因上级召唤被送入墓地时，注册一个在结束阶段发动的抽卡效果。
function c50304345.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	if r==REASON_SUMMON and rc:IsSetCard(0x8) then
		-- 效果原文内容：把这张卡解放让「英雄」怪兽上级召唤成功的回合的结束阶段发动。自己从卡组抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(50304345,0))  --"抽卡"
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c50304345.drtarget)
		e1:SetOperation(c50304345.droperation)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 规则层面操作：设置抽卡效果的目标玩家和抽卡数量。
function c50304345.drtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设定连锁处理中目标玩家为当前处理效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设定连锁处理中目标参数为1（表示抽1张卡）。
	Duel.SetTargetParam(1)
	-- 规则层面操作：设置当前处理的连锁的操作信息，包括抽卡效果的分类、目标玩家和抽卡数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面操作：执行抽卡效果，从卡组抽取一张卡。
function c50304345.droperation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 规则层面操作：让指定玩家从卡组抽一张卡，原因设为效果。
	Duel.Draw(p,1,REASON_EFFECT)
end
