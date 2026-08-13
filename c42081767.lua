--きのみ隠しのうっかりす
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己墓地最多3张魔法·陷阱卡为对象才能发动。那些卡除外。下个回合的结束阶段，这个效果除外的卡回到卡组。
-- ②：自己准备阶段，以自己的除外状态的1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册该卡的①和②效果：①为诱发即时效果（二速），可在自己或对方的主要阶段发动，选择自己墓地最多3张魔法·陷阱卡除外，并在下个回合结束阶段回到卡组；②为诱发选发效果，在自己准备阶段选择除外区1张魔法·陷阱卡盖放到自己场上；两效果各1回合1次。
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
-- 效果①的发动条件：仅限自己或对方的主要阶段（当前是主要阶段）才能发动。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 定义①效果可取对象：自己墓地的魔法·陷阱卡，且能够被除外。
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 当系统验证指定对象时，确认该对象在自己墓地、是魔法·陷阱卡、可除外，且控制者是自己。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc)
		and chkc:IsControler(tp) end
	-- 效果发动合法性检查：自己墓地是否存在至少1张满足条件的魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1~3张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置操作信息，告知系统本效果将除外这些对象卡，数量为选中的卡数，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_GRAVE)
end
-- 处理①效果：取出仍与效果关联的对象卡，将它们除外；对实际除外的卡记录本次效果标记，并注册一个延迟效果，在下一个结束阶段将这些卡送回卡组。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍然与效果关联的对象卡（过滤掉已离场或不受影响的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将被选中的对象卡以表侧表示除外，如果成功除外且场上存在仍位于除外区的卡，则继续设置后续延迟效果。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		-- 获取刚才除外操作中实际成功除外且仍位于除外区的卡组，用于后续追踪。
		local rg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local fid=e:GetHandler():GetFieldID()
		-- 遍历这些被除外的卡，为每张卡注册一个标志效果，记录本次效果的标识（fid），以便识别“这个效果除外的卡”。
		for rc in aux.Next(rg) do
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		rg:KeepAlive()
		-- 下个回合的结束阶段，这个效果除外的卡回到卡组。②：自己准备阶段，以自己的除外状态的1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 在延迟效果中记录本次除外的标识（fid）和当前回合数，用于判断“下个回合”的结束阶段。
		e1:SetLabel(fid,Duel.GetTurnCount())
		e1:SetLabelObject(rg)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将延迟效果e1注册到场上，使其可以在下个回合的结束阶段触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断某张卡是否带有指定的fid标记，用于筛选“这个效果除外的卡”。
function s.tdfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 延迟效果e1的触发条件：当前已到下个回合（回合数不同于发动时），并且仍存在带标记的除外卡；若不存在则清理效果并取消触发。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	-- 如果当前回合仍是发动回合（回合数未变），则延迟效果不触发，等待下个回合。
	if Duel.GetTurnCount()==turnc then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(s.tdfilter,1,nil,fid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 延迟效果处理：从标记的除外卡中筛选出仍存在且带标记的卡，将它们洗回持有者卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(s.tdfilter,nil,fid)
	if tg:GetCount()>0 then
		-- 向双方玩家展示该效果对应的卡图，提示正在执行“回到卡组”的处理。
		Duel.Hint(HINT_CARD,0,id)
		-- 显示这些卡被选中并返回卡组的动画。
		Duel.HintSelection(tg)
		-- 将筛选出的卡以效果原因送回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件：自己的准备阶段。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（即处于自己的准备阶段）。
	return Duel.GetTurnPlayer()==tp
end
-- 定义②效果可取对象：除外区的表侧表示魔法·陷阱卡，且可以被盖放。
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动时的目标选择：验证指定对象是否合法，然后让玩家从自己除外区选择1张满足条件的魔法·陷阱卡作为对象。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.setfilter(chkc) end
	-- 效果发动合法性检查：自己除外区是否存在至少1张满足条件的魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己除外区选择1张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
end
-- 处理②效果：取得选中的对象卡，若该卡仍与效果关联，则将其盖放到自己魔法与陷阱区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象中的第一张卡（也是唯一一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡盖放到自己场上（魔法与陷阱区域）。
		Duel.SSet(tp,tc)
	end
end
