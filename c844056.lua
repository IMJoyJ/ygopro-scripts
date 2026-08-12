--レッドアローズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以额外怪兽区域最多2只表侧表示怪兽为对象才能发动。那些怪兽直到结束阶段除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义该卡的发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以额外怪兽区域最多2只表侧表示怪兽为对象才能发动。那些怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示、位于额外怪兽区域且可以被除外的怪兽
function s.filter(c)
	return c:IsFaceup() and c:GetSequence()>4 and c:IsAbleToRemove()
end
-- 效果发动的目标选择与检测函数（Target）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查场上是否存在至少1只满足条件的、可作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1到2只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 设置当前连锁的操作信息，表明此效果包含除外操作，操作对象为选中的卡片组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 效果处理的执行函数（Operation），处理除外并在结束阶段将怪兽返回场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 尝试将对象怪兽因效果而暂时除外，并确认其中至少有1张卡成功进入除外区
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		-- 筛选出实际被成功除外并存在于除外区的卡片组
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local c=e:GetHandler()
		-- 遍历所有被成功除外的卡片
		for tc in aux.Next(og) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()
		-- 那些怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 注册全局延迟效果，用于在结束阶段将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有本效果标记的卡片，用于确认需要返回场上的怪兽
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
-- 检查被除外的卡片组中是否仍有带有标记的卡片存在，作为返回场上效果的启动条件
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(s.retfilter,1,nil)
end
-- 结束阶段将所有带有标记的被除外怪兽返回场上的具体操作
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.retfilter,nil)
	-- 遍历需要返回场上的卡片组
	for tc in aux.Next(g) do
		-- 将怪兽返回到其离场前的场上位置
		Duel.ReturnToField(tc)
	end
end
