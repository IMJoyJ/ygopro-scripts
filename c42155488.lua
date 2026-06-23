--ジェノミックス・ファイター
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的等级变成3星，原本攻击力变成一半。此外，1回合1次，宣言1个种族才能发动。这个回合把这张卡作为同调素材的场合，包含这张卡的那一组同调素材怪兽当作宣言的种族使用。这个效果发动过的回合，自己不能把宣言的种族以外的怪兽召唤·特殊召唤。
function c42155488.initial_effect(c)
	-- 这张卡可以不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42155488,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c42155488.ntcon)
	e1:SetOperation(c42155488.ntop)
	c:RegisterEffect(e1)
	-- 1回合1次，宣言1个种族才能发动。这个回合把这张卡作为同调素材的场合，包含这张卡的那一组同调素材怪兽当作宣言的种族使用。这个效果发动过的回合，自己不能把宣言的种族以外的怪兽召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42155488,1))  --"素材变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c42155488.dectg)
	e2:SetOperation(c42155488.decop)
	c:RegisterEffect(e2)
end
-- 召唤条件判断函数，判断是否满足不需解放的召唤条件
function c42155488.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足不需解放召唤的条件：不需解放（minc==0）、等级不低于5、场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤后处理函数，设置攻击力和等级
function c42155488.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置自身原本攻击力为1100
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
-- 宣言种族并设置不能召唤/特殊召唤非该种族怪兽的效果
function c42155488.dectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	-- 创建并注册不能召唤和特殊召唤的限制效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42155488.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(rc)
	-- 注册不能召唤的限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤/特殊召唤的判断函数，判断怪兽种族是否与宣言种族一致
function c42155488.sumlimit(e,c)
	return c:GetRace()~=e:GetLabel()
end
-- 发动效果后的处理函数，设置同调素材怪兽的种族属性
function c42155488.decop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local rc=e:GetLabel()
		c:SetHint(CHINT_RACE,rc)
		-- 创建并注册同调检查效果，使同调素材怪兽视为宣言的种族
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
-- 同调检查函数，使怪兽假设为宣言的种族
function c42155488.syncheck(e,c)
	c:AssumeProperty(ASSUME_RACE,e:GetLabel())
end
