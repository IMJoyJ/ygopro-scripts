--ジェノミックス・ファイター
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的等级变成3星，原本攻击力变成一半。此外，1回合1次，宣言1个种族才能发动。这个回合把这张卡作为同调素材的场合，包含这张卡的那一组同调素材怪兽当作宣言的种族使用。这个效果发动过的回合，自己不能把宣言的种族以外的怪兽召唤·特殊召唤。
function c42155488.initial_effect(c)
	-- 这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42155488,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c42155488.ntcon)
	e1:SetOperation(c42155488.ntop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，宣言1个种族才能发动。这个回合把这张卡作为同调素材的场合，包含这张卡的那一组同调素材怪兽当作宣言的种族使用。这个效果发动过的回合，自己不能把宣言的种族以外的怪兽召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42155488,1))  --"素材变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c42155488.dectg)
	e2:SetOperation(c42155488.decop)
	c:RegisterEffect(e2)
end
-- 无解放召唤的条件判定：当c为nil时视为可发动；实际召唤时要求是无解放召唤（minc==0）、怪兽等级不低于5，且自己场上存在空闲的主要怪兽区域。
function c42155488.ntcon(e,c,minc)
	if c==nil then return true end
	-- 实际召唤时需满足：无解放（minc==0）、等级≥5、自己主要怪兽区域有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放召唤成功后的处理：将这张卡原本攻击力变为1100（原攻击力的一半），等级变为3星，且这些变更在其离场/转移区域等重置事件时失效。
function c42155488.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 原本攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1100)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(3)
	c:RegisterEffect(e2)
end
-- 宣言种族效果的发动处理：先请求宣言1个种族并记录，然后立即为发动玩家附加本回合不能召唤·特殊召唤宣言种族以外怪兽的自肃效果。
function c42155488.dectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 显示‘请选择要宣言的种族’的提示，引导玩家进行种族宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 令当前玩家从全部种族中宣言1个种族，并将宣言结果作为种族值保存。
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	-- 这个效果发动过的回合，自己不能把宣言的种族以外的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42155488.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(rc)
	-- 把不能召唤宣言种族以外的怪兽的制约注册给当前玩家（持续到本回合结束阶段）。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 把不能特殊召唤宣言种族以外的怪兽的制约注册给当前玩家（持续到本回合结束阶段）。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃过滤条件：若怪兽的当前种族不等于宣言种族，则该怪兽不能进行召唤/特殊召唤。
function c42155488.sumlimit(e,c)
	return c:GetRace()~=e:GetLabel()
end
-- 效果处理时，若这张卡仍与发动效果关联且表侧表示，则把宣言的种族记录到卡片提示，并给这张卡赋予作为同调素材时按宣言种族处理的持续效果。
function c42155488.decop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local rc=e:GetLabel()
		c:SetHint(CHINT_RACE,rc)
		-- 这个回合把这张卡作为同调素材的场合，包含这张卡的那一组同调素材怪兽当作宣言的种族使用。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_CHECK)
		e1:SetValue(c42155488.syncheck)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetLabel(rc)
		c:RegisterEffect(e1)
	end
end
-- 在同调素材判定时，将这张卡的种族假定为宣言的种族，从而使包含这张卡的一组同调素材怪兽当作宣言的种族使用。
function c42155488.syncheck(e,c)
	c:AssumeProperty(ASSUME_RACE,e:GetLabel())
end
