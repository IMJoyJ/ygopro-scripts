--ゾルガ
-- 效果：
-- ①：这张卡为上级召唤而被解放的场合发动。自己回复2000基本分。
function c16268841.initial_effect(c)
	-- ①：这张卡为上级召唤而被解放的场合发动。自己回复2000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16268841,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCondition(c16268841.reccon)
	e1:SetTarget(c16268841.rectg)
	e1:SetOperation(c16268841.recop)
	c:RegisterEffect(e1)
end
-- 检查该卡是否因上级召唤而被解放
function c16268841.reccon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 设置效果的处理目标为解放时的控制者玩家，并设定回复2000基本分
function c16268841.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为通常召唤成功或放置怪兽的时点
	if chk==0 then return Duel.CheckEvent(EVENT_SUMMON_SUCCESS) or Duel.CheckEvent(EVENT_MSET) end
	-- 将效果的目标玩家设置为解放时的控制者
	Duel.SetTargetPlayer(e:GetLabel())
	-- 将效果的目标参数设置为2000
	Duel.SetTargetParam(2000)
	-- 设置连锁操作信息为回复2000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,e:GetLabel(),2000)
end
-- 执行回复2000基本分的效果处理
function c16268841.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
