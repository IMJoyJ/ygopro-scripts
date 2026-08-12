--光の護封陣
-- 效果：
-- 宣言1个种族。宣言的种族的全部怪兽召唤·反转召唤·特殊召唤的回合不能进行攻击宣言。
function c69296555.initial_effect(c)
	-- 宣言1个种族。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69296555.target)
	c:RegisterEffect(e1)
	-- 宣言的种族的全部怪兽召唤·反转召唤·特殊召唤的回合不能进行攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c69296555.atktg)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 此卡发动时的效果处理：由玩家宣言一个种族，并将该种族记录在永续效果中，同时在卡片上进行种族提示。
function c69296555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家发送提示信息，提示选择要宣言的种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从所有种族中宣言1个种族。
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:GetLabelObject():SetLabel(rc)
	e:GetHandler():SetHint(CHINT_RACE,rc)
end
-- 确定不能进行攻击宣言的对象：在本回合召唤、反转召唤、特殊召唤的宣言种族的怪兽。
function c69296555.atktg(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN) and c:IsRace(e:GetLabel())
end
