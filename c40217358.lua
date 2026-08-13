--ブルー・ダストン
-- 效果：
-- 这张卡不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被破坏时，这张卡的控制者的手卡随机选1张直到下个回合的准备阶段时里侧表示从游戏中除外。「蓝尘妖」在自己场上只能有1只表侧表示存在。
function c40217358.initial_effect(c)
	c:SetUniqueOnField(1,0,40217358)
	-- 对应效果原文『这张卡不能解放』中关于『不能作为上级召唤的祭品』的部分：该卡在主要怪兽区时，不能作为上级召唤的解放素材。
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
	-- 对应效果原文『也不能作为融合·同调·超量召唤的素材』中关于『不能作为融合素材』的部分：仅当该卡被用于融合召唤时，不可作为融合素材。
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
	-- 对应效果原文『场上的这张卡被破坏时，这张卡的控制者的手卡随机选1张直到下个回合的准备阶段时里侧表示从游戏中除外。』：注册这张卡被破坏时触发的必发效果，其发动条件、发动时设定和效果处理均在相关子函数中实现。
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
-- 判定召唤类型：仅当当前素材的召唤方式为融合召唤时返回真，从而限制该卡不能作为融合召唤的素材。
function c40217358.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 触发条件：这张卡因被破坏而离场，且破坏前位于场上区域（怪兽区或魔法陷阱区）时才满足发动条件。
function c40217358.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动时处理：获取这张卡被破坏前的控制者作为效果对象玩家，并登记效果类别为除外、对象为那位玩家手牌中的1张卡。
function c40217358.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local pre=e:GetHandler():GetPreviousControler()
	-- 把这张卡被破坏前的控制者设为当前连锁的对象玩家，以便效果处理时确定是从谁的手牌随机除外1张。
	Duel.SetTargetPlayer(pre)
	-- 登记操作信息：声明本次效果将把对象玩家的1张手牌以除外的方式处理，位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,pre,LOCATION_HAND)
end
-- 效果处理：取出对象玩家，若其手牌为空则直接结束；否则随机选择1张手牌里侧表示除外，给该卡设置本次除外标记，并注册一个在下个准备阶段将它返回手牌的持续效果。
function c40217358.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果对象玩家，即这张卡被破坏前的控制者，用于后续从其手牌中随机选择卡片。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该对象玩家手牌中的所有卡组成集合，以便后续随机抽取1张。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(p,1)
	-- 将随机选出的那张手牌以里侧表示从游戏中除外，原因记为效果。
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	local tc=sg:GetFirst()
	tc:RegisterFlagEffect(40217358,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 对应效果原文『直到下个回合的准备阶段时里侧表示从游戏中除外』中关于『直到下个回合的准备阶段时』的实现：注册一个在下一个准备阶段将暂时除外的卡返回手牌的持续效果，并设置对应的返回条件与返回处理。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c40217358.retcon)
	e1:SetOperation(c40217358.retop)
	-- 记录返回效果的预定回合：当前回合数加1，即下一个回合的准备阶段。
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetLabelObject(tc)
	-- 将这个准备阶段返回的持续效果注册到场上，由当前效果使用者管理，使其在之后满足条件时自动发动。
	Duel.RegisterEffect(e1,tp)
end
-- 返回效果的触发条件：当前回合数等于之前记录的下个回合数，也就是到达下个准备阶段时满足条件。
function c40217358.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否已经到达记录的那个准备阶段回合，是则返回真，使返回效果可以执行。
	return Duel.GetTurnCount()==e:GetLabel()
end
-- 返回处理：取出被暂时除外的卡；若该卡仍带有本次除外的标记（即没有被其他效果移动或重置），则将其返回持有者手牌，最后重置这个等待效果。
function c40217358.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(40217358)~=0 then
		-- 将该卡送回其持有者的手牌，完成暂时除外后的归还处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	e:Reset()
end
