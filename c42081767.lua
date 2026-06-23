--きのみ隠しのうっかりす
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己墓地最多3张魔法·陷阱卡为对象才能发动。那些卡除外。下个回合的结束阶段，这个效果除外的卡回到卡组。
-- ②：自己准备阶段，以自己的除外状态的1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己墓地最多3张魔法·陷阱卡为对象才能发动。那些卡除外。下个回合的结束阶段，这个效果除外的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段，以自己的除外状态的1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前为自己的主要阶段
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果①的发动条件：当前为自己的主要阶段
	return Duel.IsMainPhase()
end
-- 效果①的目标过滤器：墓地的魔法·陷阱卡且能除外
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果①的目标选择处理：目标为己方墓地的魔法·陷阱卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc)
		and chkc:IsControler(tp) end
	-- 效果①的发动检查：确认己方墓地存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果①的提示信息：提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果①的目标选择：选择1~3张己方墓地的魔法·陷阱卡
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 效果①的操作信息设置：设置除外的卡为操作对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_GRAVE)
end
-- 效果①的发动处理：将目标卡除外，并设置返回卡组的处理
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡组，并过滤出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 执行除外操作：将目标卡除外，若成功且有卡被除外则继续处理
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		-- 获取实际被除外的卡组
		local rg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local fid=e:GetHandler():GetFieldID()
		-- 遍历被除外的卡，为每张卡设置标记
		for rc in aux.Next(rg) do
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		rg:KeepAlive()
		-- 创建一个在结束阶段触发的效果，用于将卡送回卡组
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 为效果设置标签，记录场ID和回合数
		e1:SetLabel(fid,Duel.GetTurnCount())
		e1:SetLabelObject(rg)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将效果注册到玩家环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回卡的标记ID是否匹配
function s.tdfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 判断是否为下个回合的结束阶段，决定是否执行送回卡组
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	-- 判断是否为当前回合，若为当前回合则不执行
	if Duel.GetTurnCount()==turnc then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(s.tdfilter,1,nil,fid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行送回卡组的操作：将标记的卡送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(s.tdfilter,nil,fid)
	if tg:GetCount()>0 then
		-- 提示发动卡片的动画
		Duel.Hint(HINT_CARD,0,id)
		-- 显示被选为对象的卡的动画
		Duel.HintSelection(tg)
		-- 将卡送回卡组
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件：当前为自己的准备阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果②的发动条件：当前为自己的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的目标过滤器：除外状态的魔法·陷阱卡且能盖放
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的目标选择处理：目标为己方除外状态的魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.setfilter(chkc) end
	-- 效果②的发动检查：确认己方除外状态存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 效果②的提示信息：提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 效果②的目标选择：选择1张己方除外状态的魔法·陷阱卡
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
end
-- 效果②的发动处理：将目标卡盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将卡盖放
		Duel.SSet(tp,tc)
	end
end
