--未界域－ユーマリア大陸
-- 效果：
-- ①：只要这张卡在场地区域存在，自己场上的「未界域」怪兽在特殊召唤的回合不会成为对方的效果的对象。
-- ②：1回合1次，以自己场上1只「未界域」怪兽为对象才能发动。只要那只怪兽和这张卡在自己场上表侧表示存在，那只怪兽可以直接攻击，不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
function c79698395.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己场上的「未界域」怪兽在特殊召唤的回合不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c79698395.target)
	-- 设置不能成为对方卡的效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只「未界域」怪兽为对象才能发动。只要那只怪兽和这张卡在自己场上表侧表示存在，那只怪兽可以直接攻击，不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79698395,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c79698395.efftg)
	e3:SetOperation(c79698395.effop)
	c:RegisterEffect(e3)
	-- 只要那只怪兽和这张卡在自己场上表侧表示存在，那只怪兽可以直接攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 过滤自己场上在特殊召唤的回合的「未界域」怪兽。
function c79698395.target(e,c)
	return c:IsSetCard(0x11e) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 过滤自己场上表侧表示的「未界域」怪兽。
function c79698395.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x11e)
end
-- 效果②的Target函数，用于检查并选择自己场上1只表侧表示的「未界域」怪兽作为对象。
function c79698395.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c79698395.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「未界域」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c79698395.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「未界域」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c79698395.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的Operation函数，使这张卡与目标怪兽建立对象关联，从而适用后续的直接攻击和不会被作为攻击对象的效果。
function c79698395.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
