--スライム増殖炉
-- 效果：
-- 每次自己的准备阶段，在自己场上把1只「史莱姆怪兽衍生物」（水族·水·1星·攻/守500）攻击表示特殊召唤。只要这张卡在场上存在，自己不能把「史莱姆怪兽衍生物」以外的怪兽召唤·反转召唤·特殊召唤。
function c21770260.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，于准备阶段发动，特殊召唤史莱姆怪兽衍生物
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21770260,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c21770260.spcon)
	e2:SetTarget(c21770260.sptg)
	e2:SetOperation(c21770260.spop)
	c:RegisterEffect(e2)
	-- 自己不能把「史莱姆怪兽衍生物」以外的怪兽召唤·反转召唤·特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c21770260.sumlimit)
	c:RegisterEffect(e3)
	-- 自己不能把「史莱姆怪兽衍生物」以外的怪兽召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
end
-- 限制目标怪兽不能是史莱姆怪兽衍生物
function c21770260.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsCode(21770261)
end
-- 判断是否为自己的准备阶段
function c21770260.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 设置效果处理时的连锁信息，包含衍生物和特殊召唤
function c21770260.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息为衍生物类别
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息为特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理特殊召唤史莱姆怪兽衍生物的效果
function c21770260.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空余怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤史莱姆怪兽衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21770261,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_ATTACK) then
		-- 创建史莱姆怪兽衍生物
		local token=Duel.CreateToken(tp,21770261)
		-- 将史莱姆怪兽衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
