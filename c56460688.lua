--異次元隔離マシーン
-- 效果：
-- 从自己和对方场上各选择1只怪兽，从游戏中除外。这张卡被破坏并送去墓地时，被除外怪兽以相同的表示形式回到原本所在的场上。
function c56460688.initial_effect(c)
	-- 从自己和对方场上各选择1只怪兽，从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c56460688.target)
	e1:SetOperation(c56460688.operation)
	c:RegisterEffect(e1)
	-- 这张卡被破坏并送去墓地时，被除外怪兽以相同的表示形式回到原本所在的场上。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c56460688.retcon)
	e2:SetOperation(c56460688.retop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 效果发动时的对象选择与合法性检查
function c56460688.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可以除外的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只可以除外的怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可以除外的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	if e:GetLabelObject() then
		e:GetLabelObject():DeleteGroup()
		e:SetLabelObject(nil)
	end
	-- 设置操作信息，表明此效果的处理为除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
-- 效果处理：将选择的怪兽暂时除外，并为除外的怪兽和这张卡注册标记以用于后续返回场上
function c56460688.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与此效果相关的对象怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些对象怪兽因效果暂时除外，并判断是否成功除外
	if Duel.Remove(tg,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 获取本次操作实际被除外的怪兽卡片组
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(56460688,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end
		c:RegisterFlagEffect(56460688,RESET_EVENT+0x17a0000,0,1)
		g:KeepAlive()
		e:SetLabelObject(g)
	end
end
-- 检查这张卡是否带有标记、是否因破坏送去墓地，以及是否存在被除外的怪兽
function c56460688.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(56460688)~=0 and bit.band(r,REASON_DESTROY)~=0
		and e:GetLabelObject():GetLabelObject()~=nil
end
-- 将被除外且带有标记的怪兽以原本的表示形式返回场上，并清除相关标记
function c56460688.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(56460688)>0 then
			-- 将被除外的怪兽以离场前的表示形式返回到原本所在的场上
			Duel.ReturnToField(tc)
		end
		tc=g:GetNext()
	end
	g:DeleteGroup()
	e:GetLabelObject():SetLabelObject(nil)
end
