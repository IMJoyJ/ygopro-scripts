--光の結界
-- 效果：
-- ①：自己准备阶段发动。进行1次投掷硬币，里出现的场合，这张卡的②③的效果直到下次的自己准备阶段无效。
-- ②：自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
-- ③：自己的「秘仪之力」怪兽战斗破坏对方怪兽的场合发动。自己基本分回复那只破坏的怪兽的原本攻击力的数值。
function c73206827.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段发动。进行1次投掷硬币，里出现的场合，这张卡的②③的效果直到下次的自己准备阶段无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73206827,0))  --"投掷硬币"
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c73206827.coincon)
	e2:SetTarget(c73206827.cointg)
	e2:SetOperation(c73206827.coinop)
	c:RegisterEffect(e2)
	-- ②：自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(73206827)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c73206827.effectcon)
	c:RegisterEffect(e3)
	-- ③：自己的「秘仪之力」怪兽战斗破坏对方怪兽的场合发动。自己基本分回复那只破坏的怪兽的原本攻击力的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(73206827,1))  --"回复"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c73206827.reccon)
	e4:SetTarget(c73206827.rectg)
	e4:SetOperation(c73206827.recop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：判断当前是否为自己的回合
function c73206827.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是自己
	return tp==Duel.GetTurnPlayer()
end
-- 效果①的发动准备：设置投掷硬币的操作信息
function c73206827.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为投掷1次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果①的效果处理：进行1次投掷硬币，若为反面（0）则给这张卡注册Flag效果，使其②③效果直到下次自己的准备阶段无效
function c73206827.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家投掷1次硬币并获取结果
	local res=Duel.TossCoin(tp,1)
	if res==0 then
		c:RegisterFlagEffect(73206828,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	end
end
-- 判断这张卡的②③效果是否有效（未注册无效Flag，或该卡具有不被无效的抗性）
function c73206827.effectcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(73206828)==0 or c:IsHasEffect(EFFECT_CANNOT_DISABLE)
end
-- 效果③的发动条件：这张卡的效果未被无效，且自己场上的「秘仪之力」怪兽在战斗中破坏了怪兽
function c73206827.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return c73206827.effectcon(e) and rc:IsRelateToBattle() and rc:IsSetCard(0x5) and rc:IsFaceup() and rc:IsControler(tp)
end
-- 效果③的发动准备：获取被战斗破坏怪兽的原本攻击力，并设置回复基本分的操作信息
function c73206827.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst():GetBattleTarget()
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(atk)
	-- 设置当前连锁的操作信息为回复指定数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
-- 效果③的效果处理：获取目标玩家和回复数值，使该玩家回复对应的基本分
function c73206827.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和回复数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if d>0 then
		-- 因效果使目标玩家回复对应的基本分
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
