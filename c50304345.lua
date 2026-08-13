--E-HERO ヘル・ブラット
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ②：把这张卡解放让「英雄」怪兽上级召唤成功的回合的结束阶段发动。自己从卡组抽1张。
function c50304345.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50304345.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放让「英雄」怪兽上级召唤成功的回合的结束阶段发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetOperation(c50304345.regop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的处理函数：若c为空代表询问是否可以进行特殊召唤，返回true；否则检查自己场上没有怪兽且主要怪兽区有空位，满足条件才允许从手卡攻击表示特殊召唤。
function c50304345.spcon(e,c)
	if c==nil then return true end
	-- 检查该怪兽的控制者场上的主要怪兽区是否存在至少1个可用的空格，用于特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查该怪兽的控制者场上的主要怪兽区怪兽数量为0，即自己场上没有怪兽存在。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
-- 作为这张卡被使用的素材时的触发处理：若这张卡是被解放用于上级召唤，且上级召唤成功的怪兽是「英雄」怪兽，则在墓地注册一个结束阶段抽卡的效果；否则不做处理。
function c50304345.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	if r==REASON_SUMMON and rc:IsSetCard(0x8) then
		-- 自己从卡组抽1张。
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
-- 抽卡效果发动前的条件判定与信息设置：在效果发动时（chk==0）返回true允许发动，并设置抽卡玩家为tp、抽卡数量为1，同时声明本效果属于抽卡类效果。
function c50304345.drtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为tp，即抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本连锁要执行的操作为抽卡，目标玩家为tp，预计抽1张卡（因不取对象，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理函数：取得之前设置的对象玩家p，并让p抽1张卡。
function c50304345.droperation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果的对象玩家，即抽卡的玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让玩家p以效果原因抽1张卡，完成抽卡动作。
	Duel.Draw(p,1,REASON_EFFECT)
end
