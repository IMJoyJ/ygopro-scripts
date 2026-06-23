--光の精霊 ディアーナ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只光属性怪兽除外的场合可以特殊召唤。
-- ①：对方结束阶段发动。自己回复1000基本分。
function c17257342.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只光属性怪兽除外的场合可以特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17257342.spcon)
	e1:SetTarget(c17257342.sptg)
	e1:SetOperation(c17257342.spop)
	c:RegisterEffect(e1)
	-- 对方结束阶段发动。自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c17257342.reccon)
	e2:SetTarget(c17257342.rectg)
	e2:SetOperation(c17257342.recop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地是否存在光属性且可除外的怪兽
function c17257342.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤的发动条件，判断场上是否有空位且墓地存在光属性怪兽
function c17257342.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的场上主怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家的墓地是否存在至少1只光属性怪兽
		and Duel.IsExistingMatchingCard(c17257342.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤时选择除外的光属性怪兽
function c17257342.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家墓地中所有光属性怪兽的集合
	local g=Duel.GetMatchingGroup(c17257342.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤时执行的除外操作
function c17257342.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤理由除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 回复效果的发动条件，判断是否为对方的结束阶段
function c17257342.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()~=tp
end
-- 回复效果的发动时点处理，设置目标玩家和回复数值
function c17257342.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前卡的控制者
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置效果的操作信息为回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 回复效果的处理函数，执行回复基本分操作
function c17257342.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
