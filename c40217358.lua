--ブルー・ダストン
-- 效果：
-- 这张卡不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被破坏时，这张卡的控制者的手卡随机选1张直到下个回合的准备阶段时里侧表示从游戏中除外。「蓝尘妖」在自己场上只能有1只表侧表示存在。
function c40217358.initial_effect(c)
	c:SetUniqueOnField(1,0,40217358)
	-- 这张卡不能解放
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- 也不能作为融合·同调·超量召唤的素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c40217358.fuslimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	-- 场上的这张卡被破坏时，这张卡的控制者的手卡随机选1张直到下个回合的准备阶段时里侧表示从游戏中除外
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(40217358,0))  --"除外"
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c40217358.rmcon)
	e6:SetTarget(c40217358.rmtg)
	e6:SetOperation(c40217358.rmop)
	c:RegisterEffect(e6)
end
-- 效果作用：限制融合素材
function c40217358.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 效果作用：破坏时发动的条件判断
function c40217358.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果作用：设置连锁操作信息
function c40217358.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local pre=e:GetHandler():GetPreviousControler()
	-- 设置连锁操作的目标玩家
	Duel.SetTargetPlayer(pre)
	-- 设置连锁操作的类别为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,pre,LOCATION_HAND)
end
-- 效果作用：处理破坏时的除外效果
function c40217358.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家手牌区的卡组
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(p,1)
	-- 将目标卡从游戏中除外
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	local tc=sg:GetFirst()
	tc:RegisterFlagEffect(40217358,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 设置一个在准备阶段触发的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c40217358.retcon)
	e1:SetOperation(c40217358.retop)
	-- 设置该效果触发的回合数
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetLabelObject(tc)
	-- 注册该持续效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：判断是否到达指定回合
function c40217358.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于设定的回合数
	return Duel.GetTurnCount()==e:GetLabel()
end
-- 效果作用：将除外的卡送回手牌
function c40217358.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(40217358)~=0 then
		-- 将卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	e:Reset()
end
