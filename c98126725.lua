--紫炎の参謀
-- 效果：
-- 自己场上有名字带有「六武众」的怪兽表侧表示存在的场合这张卡召唤成功时，宣言1个种族发动。只要这张卡在场上表侧表示存在，宣言的种族的怪兽不能攻击宣言，双方玩家不能把宣言的种族的怪兽特殊召唤。
function c98126725.initial_effect(c)
	-- 自己场上有名字带有「六武众」的怪兽表侧表示存在的场合这张卡召唤成功时，宣言1个种族发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98126725,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c98126725.atcon)
	e1:SetTarget(c98126725.attg)
	e1:SetOperation(c98126725.atop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「六武众」怪兽
function c98126725.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 检查自己场上是否存在表侧表示的「六武众」怪兽作为发动条件
function c98126725.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「六武众」怪兽
	return Duel.IsExistingMatchingCard(c98126725.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 在效果发动时，提示并让玩家宣言1个种族，并将宣言的种族记录在效果中
function c98126725.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家发送选择宣言种族的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从所有种族中宣言1个种族
	local ac=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(ac)
end
-- 在效果处理时，若此卡表侧表示存在，则注册限制攻击宣言和限制特殊召唤的永续效果
function c98126725.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 只要这张卡在场上表侧表示存在，宣言的种族的怪兽不能攻击宣言
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c98126725.tglimit)
	e1:SetLabel(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 双方玩家不能把宣言的种族的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c98126725.tglimit)
	e2:SetLabel(e:GetLabel())
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽的种族是否与宣言的种族相同
function c98126725.tglimit(e,c)
	return c:IsRace(e:GetLabel())
end
